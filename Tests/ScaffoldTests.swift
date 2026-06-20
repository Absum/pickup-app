//
//  ScaffoldTests.swift
//  Mastery-driven scaffolding & feedback fading thresholds.
//

import XCTest

final class ScaffoldTests: XCTestCase {

    func testLowMasteryGetsFullScaffold() {
        let level = Scaffold.level(forMastery: 0.0)
        XCTAssertEqual(level, .full)
        XCTAssertTrue(level.showsDiagram)
        XCTAssertTrue(level.showsFingerNumbers)
        XCTAssertTrue(level.showsContinuousFeedback)
    }

    func testMidMasteryDropsFingerNumbersButKeepsDiagram() {
        let level = Scaffold.level(forMastery: 0.5)
        XCTAssertEqual(level, .reduced)
        XCTAssertTrue(level.showsDiagram)
        XCTAssertFalse(level.showsFingerNumbers)
        XCTAssertTrue(level.showsContinuousFeedback)
    }

    func testMasteredGoesFromMemoryWithThinFeedback() {
        let level = Scaffold.level(forMastery: 0.85)
        XCTAssertEqual(level, .fromMemory)
        XCTAssertFalse(level.showsDiagram)         // hidden — retrieve from memory
        XCTAssertFalse(level.showsFingerNumbers)
        XCTAssertFalse(level.showsContinuousFeedback)  // flag errors only
    }

    func testFadeBoundariesMatchThresholds() {
        // Just below each threshold stays in the lower-support level.
        XCTAssertEqual(Scaffold.level(forMastery: Scaffold.reducedThreshold - 0.001), .full)
        XCTAssertEqual(Scaffold.level(forMastery: Scaffold.reducedThreshold), .reduced)
        XCTAssertEqual(Scaffold.level(forMastery: Scaffold.fromMemoryThreshold - 0.001), .reduced)
        XCTAssertEqual(Scaffold.level(forMastery: Scaffold.fromMemoryThreshold), .fromMemory)
    }

    func testFromMemoryAlignsWithMasteryGate() {
        // A skill goes "from memory" exactly when it's considered learned.
        XCTAssertEqual(Scaffold.fromMemoryThreshold, ProgressStore.masteryThreshold, accuracy: 1e-9)
    }
}
