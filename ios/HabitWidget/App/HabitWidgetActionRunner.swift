import Flutter
import Foundation

/// A dedicated Dart entrypoint keeps widget writes independent of a UI scene.
/// Calls are serialized, and success is returned only after Dart has committed
/// the record and published its replacement snapshot.
@MainActor
final class HabitWidgetActionRunner {
  static let shared = HabitWidgetActionRunner()

  private struct Request {
    let id = UUID()
    let command: HabitWidgetRequest
    let continuation: CheckedContinuation<Void, Error>
  }

  private final class ReadyHandler: HabitWidgetHostApi {
    let onReady: () throws -> Void

    init(onReady: @escaping () throws -> Void) { self.onReady = onReady }

    func ready() throws { try onReady() }
  }

  private var engine: FlutterEngine?
  private var pluginRegistry: HabitWidgetPluginRegistry?
  private var backgroundApi: HabitWidgetBackgroundApi?
  private var foregroundApi: HabitWidgetForegroundApi?
  private var requests: [Request] = []
  private var ready = false
  private var executing = false
  private var sentRequestId: UUID?
  private var timeout: DispatchWorkItem?
  private var engineGeneration = UUID()

  func setForegroundMessenger(_ messenger: FlutterBinaryMessenger) {
    foregroundApi = HabitWidgetForegroundApi(binaryMessenger: messenger)
  }

  func perform(request: HabitWidgetRequest) async throws {
    try await withCheckedThrowingContinuation { continuation in
      requests.append(Request(command: request, continuation: continuation))
      beginNext()
    }
  }

  private func beginNext() {
    guard !executing, let request = requests.first else { return }
    executing = true
    let deadline = DispatchWorkItem { [weak self] in
      self?.finish(id: request.id, result: .failure(HabitWidgetActionError.timedOut), reset: true)
    }
    timeout = deadline
    DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: deadline)

    if engine == nil { startEngine() }
    if ready { send(request) }
  }

  private func startEngine() {
    let generation = UUID()
    engineGeneration = generation
    let engine = FlutterEngine(
      name: "table_habit_widget", project: nil, allowHeadlessExecution: true)
    self.engine = engine
    // Flutter requires run() before installing any binary message handler.
    // Startup continues synchronously on the main thread, before Dart's ready
    // message can be delivered back to this handler.
    guard engine.run(withEntrypoint: "habitWidgetBackgroundMain") else {
      if let request = requests.first {
        finish(id: request.id, result: .failure(HabitWidgetActionError.unavailable), reset: true)
      }
      return
    }
    backgroundApi = HabitWidgetBackgroundApi(binaryMessenger: engine.binaryMessenger)
    let readyHandler = ReadyHandler { [weak self] in
      guard let self = self, self.engineGeneration == generation else {
        throw HabitWidgetApiError(code: "expired", message: "Widget engine expired", details: nil)
      }
      self.ready = true
      if self.executing, let request = self.requests.first { self.send(request) }
    }
    HabitWidgetHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: readyHandler)
    let pluginRegistry = HabitWidgetPluginRegistry(registry: engine)
    self.pluginRegistry = pluginRegistry
    GeneratedPluginRegistrant.register(with: pluginRegistry)
  }

  private func send(_ request: Request) {
    guard sentRequestId != request.id else { return }
    sentRequestId = request.id
    backgroundApi?.perform(request: request.command) { [weak self] response in
      switch response {
      case .success(let outcome):
        let success: Bool
        switch outcome {
        case .applied, .unchanged, .stale: success = true
        case .invalid, .failed: success = false
        }
        self?.finish(
          id: request.id,
          result: success ? .success(()) : .failure(HabitWidgetActionError.failed), reset: false)
      case .failure:
        self?.finish(id: request.id, result: .failure(HabitWidgetActionError.failed), reset: true)
      }
    }
  }

  private func finish(id: UUID, result: Result<Void, Error>, reset: Bool) {
    guard let request = requests.first, request.id == id else { return }
    timeout?.cancel()
    timeout = nil
    requests.removeFirst()
    executing = false
    sentRequestId = nil
    if reset {
      engineGeneration = UUID()
      ready = false
      if let engine = engine {
        HabitWidgetHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: nil)
      }
      backgroundApi = nil
      engine?.destroyContext()
      engine = nil
      pluginRegistry = nil
    }
    if case .success = result { foregroundApi?.changed { _ in } }
    request.continuation.resume(with: result)
    beginNext()
  }
}
