import AppIntents
import Foundation
import WidgetKit

@available(iOS 17.0, *)
enum HabitWidgetAction: String, AppEnum {
  case complete
  case undo
  case refresh

  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Habit action")
  static var caseDisplayRepresentations: [HabitWidgetAction: DisplayRepresentation] = [
    .complete: "Complete", .undo: "Undo", .refresh: "Refresh"
  ]
}

@available(iOS 17.0, *)
struct HabitWidgetActionIntent: AppIntent {
  static var title: LocalizedStringResource = "Update habit"
  static var description = IntentDescription("Complete or undo today's habit from its widget.")
  static var openAppWhenRun = false
  static var isDiscoverable = false

  @Parameter(title: "Habit") var habitId: String
  @Parameter(title: "Day") var day: String
  @Parameter(title: "Expected record") var expectedRecord: String
  @Parameter(title: "Action") var action: HabitWidgetAction

  init() {
    habitId = ""
    day = ""
    expectedRecord = ""
    action = .refresh
  }

  init(habit: HabitWidgetHabit, day: String, action: HabitWidgetAction) {
    habitId = habit.id
    self.day = day
    expectedRecord = habit.expectedRecord
    self.action = action
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    // Never act on the previous day's tile or an obsolete projection. Dart
    // additionally compares the record revision inside its write transaction.
    var operation = action
    if action != .refresh {
      let snapshot = HabitWidgetShared.readSnapshot()
      let habit = snapshot?.habits.first(where: { $0.id == habitId })
      let allowed = action == .complete ? habit?.canComplete : habit?.canUndo
      if snapshot?.isCurrent(at: .now) != true || snapshot?.day != day
          || habit?.expectedRecord != expectedRecord || allowed != true {
        // A cached button can still be tapped just after midnight. Refresh the
        // projection without forwarding yesterday's mutation to Dart.
        operation = .refresh
      }
    }

    var components = URLComponents()
    components.scheme = "tablehabit-widget"
    components.host = operation.rawValue
    components.queryItems = operation == .refresh ? nil : [
      URLQueryItem(name: "habitId", value: habitId),
      URLQueryItem(name: "day", value: day),
      URLQueryItem(name: "expectedRecord", value: expectedRecord)
    ]
    guard let url = components.url else { throw HabitWidgetActionError.invalidAction }

    #if HABIT_WIDGET_EXTENSION
      // The app-only protocol conformance below routes this intent to Runner.
      // If the system cannot do that, leave the record and snapshot untouched.
      throw HabitWidgetActionError.unavailable
    #else
      try await HabitWidgetActionRunner.shared.perform(url: url)
    #endif
    WidgetCenter.shared.reloadTimelines(ofKind: HabitWidgetShared.kind)
    return .result()
  }
}

// Ask iOS to execute in the app process, including a cold background launch.
// No foreground request is made; the runner starts a dedicated headless engine.
@available(iOS 17.0, *)
@available(iOSApplicationExtension, unavailable)
extension HabitWidgetActionIntent: ForegroundContinuableIntent {}

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
