import Foundation

/// Tracks the callback identities of one serialized engine request.
///
/// ```text
/// idle -> begin -> waiting for ready -> dispatch once -> complete -> idle
///                  ^                                      |
///                  +--------- reset engine generation ----+
/// ```
/// The runner owns scheduling and effects; this value validates transitions.
struct HabitWidgetExecutionState {
  private(set) var engineGeneration = UUID()
  private(set) var engineReady = false
  private(set) var operationID: UUID?
  private var dispatchedOperationID: UUID?

  /// Reports whether the queue head has begun execution.
  var executing: Bool { operationID != nil }

  /// Reserves an idle execution state for the next queue identity.
  mutating func begin(operationID: UUID) -> Bool {
    guard !executing else { return false }
    self.operationID = operationID
    return true
  }

  /// Allocates a new callback generation before starting a Flutter engine.
  mutating func beginEngine() -> UUID {
    engineGeneration = UUID()
    engineReady = false
    return engineGeneration
  }

  /// Checks whether a callback belongs to the current engine instance.
  func accepts(engineGeneration: UUID) -> Bool {
    self.engineGeneration == engineGeneration
  }

  /// Accepts a ready handshake only from the current engine generation.
  mutating func markReady(engineGeneration: UUID) -> Bool {
    guard accepts(engineGeneration: engineGeneration) else { return false }
    engineReady = true
    return true
  }

  /// Grants a single dispatch after the current engine has become ready.
  mutating func markDispatched(operationID: UUID) -> Bool {
    guard engineReady, isCurrent(operationID: operationID),
          dispatchedOperationID != operationID else { return false }
    dispatchedOperationID = operationID
    return true
  }

  /// Checks completion identity without changing the active queue state.
  func isCurrent(operationID: UUID) -> Bool { self.operationID == operationID }

  /// Releases a matching operation and optionally invalidates engine callbacks.
  @discardableResult
  mutating func complete(operationID: UUID, resetEngine: Bool) -> Bool {
    guard isCurrent(operationID: operationID) else { return false }
    self.operationID = nil
    dispatchedOperationID = nil
    if resetEngine {
      engineGeneration = UUID()
      engineReady = false
    }
    return true
  }
}
