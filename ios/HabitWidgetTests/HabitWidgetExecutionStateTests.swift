import Foundation
import XCTest

final class HabitWidgetExecutionStateTests: XCTestCase {
  func testQueueHeadCannotBeReplacedUntilMatchingCompletion() {
    var state = HabitWidgetExecutionState()
    let first = UUID()
    let second = UUID()
    XCTAssertTrue(state.begin(operationID: first))
    XCTAssertFalse(state.begin(operationID: second))
    XCTAssertFalse(state.complete(operationID: second, resetEngine: true))
    XCTAssertTrue(state.isCurrent(operationID: first))
    XCTAssertTrue(state.complete(operationID: first, resetEngine: false))
    XCTAssertFalse(state.executing)
    XCTAssertTrue(state.begin(operationID: second))
  }

  func testReadyHandshakeIsRequiredAndRepeatedHandshakeCannotDispatchTwice() {
    var state = HabitWidgetExecutionState()
    let operation = UUID()
    XCTAssertTrue(state.begin(operationID: operation))
    let engine = state.beginEngine()
    XCTAssertFalse(state.markDispatched(operationID: operation))
    XCTAssertFalse(state.markReady(engineGeneration: UUID()))
    XCTAssertFalse(state.engineReady)
    XCTAssertTrue(state.markReady(engineGeneration: engine))
    XCTAssertFalse(state.markDispatched(operationID: UUID()))
    XCTAssertTrue(state.markDispatched(operationID: operation))
    XCTAssertTrue(state.markReady(engineGeneration: engine))
    XCTAssertFalse(state.markDispatched(operationID: operation))
  }

  func testTimeoutInvalidatesOldEngineAndLateCompletionCannotFinishNextRequest() {
    var state = HabitWidgetExecutionState()
    let expired = UUID()
    let next = UUID()
    XCTAssertTrue(state.begin(operationID: expired))
    let oldEngine = state.beginEngine()
    XCTAssertTrue(state.markReady(engineGeneration: oldEngine))
    XCTAssertTrue(state.markDispatched(operationID: expired))
    XCTAssertTrue(state.complete(operationID: expired, resetEngine: true))
    XCTAssertFalse(state.accepts(engineGeneration: oldEngine))
    XCTAssertTrue(state.begin(operationID: next))
    let newEngine = state.beginEngine()
    XCTAssertFalse(state.markReady(engineGeneration: oldEngine))
    XCTAssertFalse(state.complete(operationID: expired, resetEngine: true))
    XCTAssertTrue(state.isCurrent(operationID: next))
    XCTAssertTrue(state.accepts(engineGeneration: newEngine))
    XCTAssertFalse(state.markDispatched(operationID: next))
    XCTAssertTrue(state.markReady(engineGeneration: newEngine))
    XCTAssertTrue(state.markDispatched(operationID: next))
  }

  func testSuccessfulCompletionReusesReadyEngineAndIgnoresDuplicateReply() {
    var state = HabitWidgetExecutionState()
    let first = UUID()
    let second = UUID()
    XCTAssertTrue(state.begin(operationID: first))
    let engine = state.beginEngine()
    XCTAssertTrue(state.markReady(engineGeneration: engine))
    XCTAssertTrue(state.markDispatched(operationID: first))
    XCTAssertTrue(state.complete(operationID: first, resetEngine: false))
    XCTAssertFalse(state.complete(operationID: first, resetEngine: true))
    XCTAssertTrue(state.engineReady)
    XCTAssertTrue(state.accepts(engineGeneration: engine))
    XCTAssertTrue(state.begin(operationID: second))
    XCTAssertTrue(state.markDispatched(operationID: second))
    XCTAssertFalse(state.markDispatched(operationID: first))
    XCTAssertTrue(state.isCurrent(operationID: second))
  }

  func testReplacementEngineRequiresItsOwnReadyHandshake() {
    var state = HabitWidgetExecutionState()
    let operation = UUID()
    XCTAssertTrue(state.begin(operationID: operation))
    let previous = state.beginEngine()
    XCTAssertTrue(state.markReady(engineGeneration: previous))
    let replacement = state.beginEngine()
    XCTAssertNotEqual(previous, replacement)
    XCTAssertFalse(state.engineReady)
    XCTAssertFalse(state.markReady(engineGeneration: previous))
    XCTAssertFalse(state.markDispatched(operationID: operation))
    XCTAssertTrue(state.markReady(engineGeneration: replacement))
    XCTAssertTrue(state.markDispatched(operationID: operation))
  }
}
