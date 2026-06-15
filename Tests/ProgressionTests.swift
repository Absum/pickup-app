//
//  ProgressionTests.swift
//  Chord progressions resolve to real chords in the bank.
//

import XCTest

final class ProgressionTests: XCTestCase {
    func testProgressionsResolveToChords() {
        for prog in ChordProgressions.all {
            XCTAssertEqual(prog.chords.count, prog.chordIDs.count,
                           "\(prog.name): every chord id should resolve to a bank chord")
        }
    }
}
