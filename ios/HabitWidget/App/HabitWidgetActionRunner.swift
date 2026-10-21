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
    let url: URL
    let continuation: CheckedContinuation<Void, Error>
  }

  private var engine: FlutterEngine?
  private var pluginRegistry: HabitWidgetPluginRegistry?
  private var channel: FlutterMethodChannel?
  private var foregroundChannel: FlutterMethodChannel?
  private var requests: [Request] = []
  private var ready = false
  private var executing = false
  private var sentRequestId: UUID?
  private var timeout: DispatchWorkItem?
  private var engineGeneration = UUID()

  func setForegroundMessenger(_ messenger: FlutterBinaryMessenger) {
    foregroundChannel = FlutterMethodChannel(
      name: "table_habit/widget_foreground", binaryMessenger: messenger)
  }

  func perform(url: URL) async throws {
    try await withCheckedThrowingContinuation { continuation in
      requests.append(Request(url: url, continuation: continuation))
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
    let channel = FlutterMethodChannel(
      name: "table_habit/widget_background", binaryMessenger: engine.binaryMessenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self, self.engineGeneration == generation else {
        result(FlutterError(code: "expired", message: "Widget engine expired", details: nil))
        return
      }
      guard call.method == "ready" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.ready = true
      result(true)
      if self.executing, let request = self.requests.first { self.send(request) }
    }
    let pluginRegistry = HabitWidgetPluginRegistry(registry: engine)
    self.pluginRegistry = pluginRegistry
    GeneratedPluginRegistrant.register(with: pluginRegistry)
  }

  private func send(_ request: Request) {
    guard sentRequestId != request.id else { return }
    sentRequestId = request.id
    channel?.invokeMethod("perform", arguments: request.url.absoluteString) { [weak self] response in
      let success = (response as? Bool) == true
      self?.finish(
        id: request.id,
        result: success ? .success(()) : .failure(HabitWidgetActionError.failed),
        reset: response is FlutterError)
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
      channel?.setMethodCallHandler(nil)
      channel = nil
      engine?.destroyContext()
      engine = nil
      pluginRegistry = nil
    }
    if case .success = result { foregroundChannel?.invokeMethod("changed", arguments: nil) }
    request.continuation.resume(with: result)
    beginNext()
  }
}
