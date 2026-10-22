import AppIntents
import Foundation
import WidgetKit

/// Defines the actions exposed by native widget controls.
@available(iOS 17.0, *)
enum HabitWidgetAction: String, AppEnum {
  case complete
  case undo
  case refresh
  case next

  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Habit action")
  static var caseDisplayRepresentations: [HabitWidgetAction: DisplayRepresentation] = [
    .complete: "Complete", .undo: "Undo", .refresh: "Refresh", .next: "Next"
  ]
}

@available(iOS 17.0, *)
extension HabitWidgetSource: AppEnum {
  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Selection source")
  static var caseDisplayRepresentations: [HabitWidgetSource: DisplayRepresentation] = [
    .automatic: "Automatic", .fixed: "Fixed"
  ]
}

/// Routes serialized widget-control parameters to the app-process executor.
@available(iOS 17.0, *)
struct HabitWidgetActionIntent: AppIntent {
  static var title: LocalizedStringResource = "Update habit"
  static var description = IntentDescription("Complete or undo today's habit from its widget.")
  static var openAppWhenRun = false
  static var isDiscoverable = false

  @Parameter(title: "Habit") var habitId: String
  @Parameter(title: "Day") var day: String
  @Parameter(title: "Expected record") var expectedRecord: String
  @Parameter(title: "Hold identity") var holdIdentity: String
  @Parameter(title: "Selection source") var source: HabitWidgetSource
  @Parameter(title: "Action") var action: HabitWidgetAction

  /// Creates a parameterless refresh action for loading and stale views.
  init() {
    habitId = ""
    day = ""
    expectedRecord = ""
    holdIdentity = ""
    source = .automatic
    action = .refresh
  }

  /// Captures the displayed entity and version for subsequent validation.
  init(habit: HabitWidgetHabit, day: String, action: HabitWidgetAction, source: HabitWidgetSource = .fixed, holdIdentity: String? = nil) {
    habitId = habit.id
    self.day = day
    expectedRecord = habit.expectedRecord
    self.action = action
    self.source = source
    self.holdIdentity = holdIdentity ?? ""
  }

  /// Executes a validated app-process request and requests a fresh timeline.
  @MainActor
  func perform() async throws -> some IntentResult {
    // All date/version/identity checks happen at the head of Runner's queue,
    // so a queued Undo or Next cannot consume a later completion's identity.
    #if HABIT_WIDGET_EXTENSION
      // The app-only protocol conformance below routes this intent to Runner.
      // If the system cannot do that, leave the record and snapshot untouched.
      try requireAppProcess()
    #else
      if action == .next {
        guard source == .automatic else { throw HabitWidgetActionError.invalidAction }
        try await HabitWidgetActionRunner.shared.advance(HabitWidgetHoldEvent(
          habitID: habitId, day: day, recordVersion: expectedRecord, identity: holdIdentity))
        return .result()
      }
      let wireOperation: HabitWidgetOperation
      switch action {
      case .complete: wireOperation = .complete
      case .undo: wireOperation = .undo
      case .refresh: wireOperation = .refresh
      case .next: wireOperation = .refresh
      }
      let request = HabitWidgetRequest(
        operation: wireOperation,
        source: action == .refresh ? nil : (source == .fixed ? .fixed : .automatic),
        habitId: action == .refresh ? nil : habitId,
        day: action == .refresh ? nil : day,
        expectedRecord: action == .refresh ? nil : expectedRecord)
      let response = try await HabitWidgetActionRunner.shared.perform(request: request, holdIdentity: holdIdentity.isEmpty ? nil : holdIdentity)
      if response.outcome == .invalid || response.outcome == .failed {
        throw HabitWidgetActionError.failed
      }
    #endif
    WidgetCenter.shared.reloadTimelines(ofKind: HabitWidgetShared.kind)
    return .result()
  }

  /// Rejects execution when the system has not routed the action to Runner.
  private func requireAppProcess() throws {
    throw HabitWidgetActionError.unavailable
  }
}

// Ask iOS to execute in the app process, including a cold background launch.
// No foreground request is made; the runner starts a dedicated headless engine.
@available(iOS 17.0, *)
@available(iOSApplicationExtension, unavailable)
extension HabitWidgetActionIntent: ForegroundContinuableIntent {}

/// Describes failures returned to the system's intent execution surface.
enum HabitWidgetActionError: Error, LocalizedError {
  case invalidAction, unavailable, timedOut, failed

  var errorDescription: String? {
    switch self {
    case .invalidAction: return "This habit action is no longer available."
    case .unavailable: return "Open Table Habit once before using widget actions."
    case .timedOut: return "The habit could not be updated in time. Please try again."
    case .failed: return "The habit could not be updated. Refresh the widget and try again."
    }
  }
}
