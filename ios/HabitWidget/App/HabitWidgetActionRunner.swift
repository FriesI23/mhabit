import Flutter
import Foundation
import OSLog
import WidgetKit

/// Serializes widget requests and display-state updates in the app process.
///
/// ```text
/// App intent ----> FIFO queue ----> Dart API ----> response
///                     ^                             |
/// Publication --------+                     persist display state
///                                                   |
///                                            reload -> resume
/// ```
@MainActor
final class HabitWidgetActionRunner {
  static let shared = HabitWidgetActionRunner()

  /// Identifiers used to create and launch the dedicated Flutter engine.
  private enum BackgroundEngineConfiguration {
    static let name = "table_habit_widget"
    static let entrypoint = "habitWidgetBackgroundMain"
    static let responseTimeout: TimeInterval = 20
  }

  /// An operation whose effects must remain ordered with snapshot publication.
  private enum QueuedWidgetOperation {
    case recordAction(HabitWidgetRequest, holdIdentity: String?)
    case advanceDisplay(HabitWidgetHoldEvent)
    case snapshotPublished(HabitWidgetSnapshot?)
  }

  /// Associates an operation with its callback identity and optional caller.
  private struct PendingWidgetOperation {
    let id = UUID()
    let operation: QueuedWidgetOperation
    let continuation: CheckedContinuation<HabitWidgetResponse, Error>?
  }

  /// Adapts the Dart initialization handshake to the runner's current engine.
  private final class ReadyHandler: HabitWidgetHostApi {
    let onReady: () throws -> Void
    init(onReady: @escaping () throws -> Void) { self.onReady = onReady }
    func ready() throws { try onReady() }
  }

  /// Acknowledges publication as soon as its snapshot has entered the queue.
  private final class DisplayHandler: HabitWidgetDisplayHostApi {
    let onPublished: () -> Void
    init(onPublished: @escaping () -> Void) { self.onPublished = onPublished }
    func published() { onPublished() }
  }

  private let holds = HabitWidgetHoldStore()
  private var engine: FlutterEngine?
  private var pluginRegistry: HabitWidgetPluginRegistry?
  private var backgroundApi: HabitWidgetBackgroundApi?
  private var foregroundApi: HabitWidgetForegroundApi?
  private var pendingOperations: [PendingWidgetOperation] = []
  private var execution = HabitWidgetExecutionState()
  private var preparedCommand: HabitWidgetRequest?
  private var timeout: DispatchWorkItem?

  /// Attaches the visible Flutter engine without sharing its API messenger.
  func setForegroundMessenger(_ messenger: FlutterBinaryMessenger) {
    foregroundApi = HabitWidgetForegroundApi(binaryMessenger: messenger)
    installDisplayHandler(messenger)
  }

  /// Captures publications before acknowledging them, without awaiting execution.
  private func installDisplayHandler(_ messenger: FlutterBinaryMessenger, generation: UUID? = nil) {
    let handler = DisplayHandler { [weak self] in
      guard let self else { return }
      if let generation, !self.execution.accepts(engineGeneration: generation) { return }
      // Capture this publication now, so an intermediate data reset cannot be
      // hidden by a later publication which restores the same record values.
      self.pendingOperations.append(PendingWidgetOperation(operation: .snapshotPublished(HabitWidgetShared.readSnapshot()), continuation: nil))
      self.beginNext()
    }
    HabitWidgetDisplayHostApiSetup.setUp(binaryMessenger: messenger, api: handler)
  }

  /// Enqueues a record request and returns its validated execution result.
  func perform(request: HabitWidgetRequest, holdIdentity: String? = nil) async throws -> HabitWidgetResponse {
    try await withCheckedThrowingContinuation { continuation in
      pendingOperations.append(PendingWidgetOperation(operation: .recordAction(request, holdIdentity: holdIdentity), continuation: continuation))
      beginNext()
    }
  }

  /// Enqueues an identity-checked display update without invoking Dart.
  func advance(_ event: HabitWidgetHoldEvent) async throws {
    let _: HabitWidgetResponse = try await withCheckedThrowingContinuation { continuation in
      pendingOperations.append(PendingWidgetOperation(operation: .advanceDisplay(event), continuation: continuation))
      beginNext()
    }
  }

  /// Starts the queue head only after the previous operation has finished.
  private func beginNext() {
    guard let request = pendingOperations.first, execution.begin(operationID: request.id) else { return }
    switch request.operation {
    case .snapshotPublished(let snapshot):
      do {
        try holds.reconcile(snapshot: snapshot, at: .now)
      } catch { logDisplayFailure(error) }
      reload()
      finish(id: request.id, result: .success(noChange()), reset: false)
    case .advanceDisplay(let event):
      do {
        try holds.advance(event, snapshot: HabitWidgetShared.readSnapshot(), at: .now)
        // Even an old event refreshes its stale presentation without consuming
        // a different identity or mutating any record.
        reload()
        finish(id: request.id, result: .success(noChange()), reset: false)
      } catch {
        finish(id: request.id, result: .failure(HabitWidgetActionError.failed), reset: false)
      }
    case .recordAction(let command, let identity):
      preparedCommand = validated(command, holdIdentity: identity)
      let deadline = DispatchWorkItem { [weak self] in
        self?.finish(id: request.id, result: .failure(HabitWidgetActionError.timedOut), reset: true)
      }
      timeout = deadline
      DispatchQueue.main.asyncAfter(deadline: .now() + BackgroundEngineConfiguration.responseTimeout, execute: deadline)
      if engine == nil { startEngine() }
      if execution.engineReady { send(request) }
    }
  }

  /// Revalidates a queued request against the snapshot visible at execution.
  private func validated(_ command: HabitWidgetRequest, holdIdentity: String?) -> HabitWidgetRequest {
    guard command.operation != .refresh else { return command }
    let snapshot = HabitWidgetShared.readSnapshot()
    let habit = snapshot?.catalog.first { $0.id == command.habitId }
    let fixed = command.source == .fixed
    let capable: Bool
    switch command.operation {
    case .complete: capable = habit?.canComplete == true
    case .markIncomplete: capable = habit?.canMarkIncomplete == true
    case .undo: capable = habit?.canUndo == true
    case .refresh: capable = false
    }
    var allowed = snapshot?.isCurrent(at: .now) == true && snapshot?.day == command.day
      && habit?.expectedRecord == command.expectedRecord
      && (habit?.state == .active || (fixed && habit?.state == .archived))
      && capable
    if !fixed {
      allowed = allowed && habit?.automaticEligible == true
      if command.operation == .undo {
        let hold = holds.validHolds(snapshot: snapshot, at: .now)[command.habitId ?? ""]
        allowed = allowed && hold != nil && hold?.identity == holdIdentity
      }
    }
    return allowed ? command : HabitWidgetRequest(operation: .refresh)
  }

  /// Starts an isolated headless engine and rejects callbacks from older engines.
  private func startEngine() {
    let generation = execution.beginEngine()
    let engine = FlutterEngine(name: BackgroundEngineConfiguration.name, project: nil, allowHeadlessExecution: true)
    self.engine = engine
    guard engine.run(withEntrypoint: BackgroundEngineConfiguration.entrypoint) else {
      if let request = pendingOperations.first {
        finish(id: request.id, result: .failure(HabitWidgetActionError.unavailable), reset: true)
      }
      return
    }
    backgroundApi = HabitWidgetBackgroundApi(binaryMessenger: engine.binaryMessenger)
    let handler = ReadyHandler { [weak self] in
      guard let self, self.execution.markReady(engineGeneration: generation) else {
        throw HabitWidgetApiError(code: "expired", message: "Widget engine expired", details: nil)
      }
      if self.execution.executing, let request = self.pendingOperations.first { self.send(request) }
    }
    HabitWidgetHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: handler)
    installDisplayHandler(engine.binaryMessenger, generation: generation)
    let registry = HabitWidgetPluginRegistry(registry: engine)
    pluginRegistry = registry
    GeneratedPluginRegistrant.register(with: registry)
  }

  /// Dispatches the current request once, including repeated ready handshakes.
  private func send(_ request: PendingWidgetOperation) {
    guard let command = preparedCommand, execution.markDispatched(operationID: request.id) else { return }
    backgroundApi?.perform(request: command) { [weak self] response in
      switch response {
      case .success(let response):
        let valid = response.outcome == .applied
          ? HabitWidgetCommit(recordVersion: response.recordVersion, committedAt: response.committedAt) != nil
          : response.recordVersion == nil && response.committedAt == nil
        self?.finish(id: request.id, result: valid ? .success(response) : .failure(HabitWidgetActionError.failed), reset: !valid)
      case .failure:
        self?.finish(id: request.id, result: .failure(HabitWidgetActionError.failed), reset: true)
      }
    }
  }

  /// Completes only the matching queue head, ignoring late or duplicate replies.
  private func finish(id: UUID, result: Result<HabitWidgetResponse, Error>, reset: Bool) {
    guard let request = pendingOperations.first, request.id == id,
          execution.isCurrent(operationID: id) else { return }
    timeout?.cancel()
    timeout = nil
    // Apply native state before releasing the queue or acknowledging the tap.
    if case .success(let response) = result, response.outcome == .applied,
       case .recordAction(_, let identity) = request.operation, let command = preparedCommand,
       let habitID = command.habitId, let day = command.day,
       let previousVersion = command.expectedRecord,
       let commit = HabitWidgetCommit(recordVersion: response.recordVersion, committedAt: response.committedAt) {
      do {
        switch command.operation {
        case .complete, .markIncomplete:
          try holds.recorded(habitID: habitID, day: day,
            source: command.source == .fixed ? .fixed : .automatic, commit: commit, at: .now,
            result: command.operation == .markIncomplete ? .incomplete : .completed)
        case .undo:
          try holds.undone(habitID: habitID, day: day, previousVersion: previousVersion,
                           identity: command.source == .fixed ? nil : identity, commit: commit)
        case .refresh: break
        }
        reload()
      } catch {
        // The DB commit is still applied if local display persistence fails.
        logDisplayFailure(error)
      }
    }
    pendingOperations.removeFirst()
    execution.complete(operationID: id, resetEngine: reset)
    preparedCommand = nil
    if reset {
      if let engine {
        HabitWidgetHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: nil)
        HabitWidgetDisplayHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: nil)
      }
      backgroundApi = nil
      engine?.destroyContext()
      engine = nil
      pluginRegistry = nil
    }
    if case .recordAction = request.operation, case .success(let response) = result,
       response.outcome != .failed && response.outcome != .invalid {
      foregroundApi?.changed { _ in }
    }
    request.continuation?.resume(with: result)
    beginNext()
  }

  private func noChange() -> HabitWidgetResponse { HabitWidgetResponse(outcome: .unchanged, snapshotPublished: false) }
  private func reload() { WidgetCenter.shared.reloadTimelines(ofKind: HabitWidgetShared.kind) }
  private func logDisplayFailure(_ error: Error) {
    Logger(subsystem: "io.github.friesi23.mhabit", category: "widget").error("Display state write failed: \(String(describing: error), privacy: .public)")
  }
}
