//
//  InterleavedDrillTests.swift
//  The interleaved-practice pool + shuffled drill generation.
//

import XCTest

final class InterleavedDrillTests: XCTestCase {

    private let threeChords: Set<String> = ["chord-em", "chord-am", "chord-d"]

    func testPoolNeedsTwoLearnedChords() {
        XCTAssertTrue(InterleavedDrill.pool(completed: []).isEmpty)
        XCTAssertEqual(InterleavedDrill.pool(completed: ["chord-em"]).count, 1)
        XCTAssertEqual(InterleavedDrill.pool(completed: threeChords).count, 3)
    }

    func testPoolIsDistinctChordsFromSingleChordLessonsOnly() {
        // Songs/changes contribute no extra pool entries — their chords already
        // come from the chord lessons. Completing only a 2-chord song yields none.
        XCTAssertTrue(InterleavedDrill.pool(completed: ["song-em-am"]).isEmpty)
        XCTAssertTrue(InterleavedDrill.pool(completed: ["change-ea"]).isEmpty)
        let ids = InterleavedDrill.pool(completed: threeChords).map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)                  // distinct
        XCTAssertEqual(Set(ids), ["Em", "Am", "D"])
    }

    func testSequenceLengthAndChordsAllFromPool() {
        var rng = SeededGenerator(seed: 42)
        let seq = InterleavedDrill.sequence(poolIDs: ["Em", "Am", "D"], length: 8, using: &rng)
        XCTAssertEqual(seq.count, 8)
        XCTAssertTrue(seq.allSatisfy { ["Em", "Am", "D"].contains($0) })
    }

    func testSequenceAvoidsImmediateRepeats() {
        var rng = SeededGenerator(seed: 7)
        let seq = InterleavedDrill.sequence(poolIDs: ["Em", "Am", "D"], length: 30, using: &rng)
        for i in 1..<seq.count {
            XCTAssertNotEqual(seq[i], seq[i - 1], "no chord should repeat back-to-back")
        }
    }

    func testSequenceSpreadsChordsEvenly() {
        var rng = SeededGenerator(seed: 99)
        let seq = InterleavedDrill.sequence(poolIDs: ["Em", "Am", "D"], length: 9, using: &rng)
        // Cycling the full pool each pass → 9/3 = exactly 3 of each.
        for id in ["Em", "Am", "D"] {
            XCTAssertEqual(seq.filter { $0 == id }.count, 3)
        }
    }

    func testGeneratedLessonIsEphemeralChordDrill() {
        var rng = SeededGenerator(seed: 1)
        let lesson = InterleavedDrill.lesson(completed: threeChords, length: 8, using: &rng)
        XCTAssertNotNil(lesson)
        XCTAssertEqual(lesson?.steps.count, 8)
        XCTAssertFalse(lesson?.tracksProgress ?? true, "the mix must not record mastery/SRS")
        XCTAssertTrue(lesson?.steps.allSatisfy { $0.chord != nil && $0.strum == nil } ?? false)
    }

    func testNoLessonWhenPoolTooSmall() {
        var rng = SeededGenerator(seed: 1)
        XCTAssertNil(InterleavedDrill.lesson(completed: ["chord-em"], using: &rng))
    }

    func testSeededGeneratorIsDeterministic() {
        var a = SeededGenerator(seed: 123)
        var b = SeededGenerator(seed: 123)
        let seqA = InterleavedDrill.sequence(poolIDs: ["Em", "Am", "D"], length: 12, using: &a)
        let seqB = InterleavedDrill.sequence(poolIDs: ["Em", "Am", "D"], length: 12, using: &b)
        XCTAssertEqual(seqA, seqB)
    }
}
