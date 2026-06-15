//
//  SongTests.swift
//  Every song's chart resolves to real chords.
//

import XCTest

final class SongTests: XCTestCase {
    func testSongBarsResolve() {
        for song in SongLibrary.all {
            XCTAssertEqual(song.bars.count, song.barChordIDs.count,
                           "\(song.title): a bar chord id did not resolve to a bank chord")
            XCTAssertFalse(song.bars.isEmpty)
        }
    }
}
