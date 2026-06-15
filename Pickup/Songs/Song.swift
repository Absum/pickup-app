//
//  Song.swift
//  Play-along song charts (public-domain / original) — one chord per bar.
//

import Foundation

struct Song: Identifiable, Hashable {
    let id: String
    let title: String
    let credit: String       // "Traditional", "Pachelbel", "Original"…
    let bpm: Int
    let beatsPerBar: Int
    let barChordIDs: [String] // one chord id per bar

    /// Resolved chords, one per bar (skips any unknown id — guarded by tests).
    var bars: [Chord] {
        barChordIDs.compactMap { id in ChordBank.all.first { $0.id == id } }
    }
}

enum SongLibrary {
    static let all: [Song] = [
        Song(id: "blues-a", title: "12-Bar Blues in A", credit: "Traditional",
             bpm: 100, beatsPerBar: 4,
             barChordIDs: ["A", "A", "A", "A", "D", "D", "A", "A", "E", "D", "A", "E"]),
        Song(id: "rising-sun", title: "House of the Rising Sun", credit: "Traditional",
             bpm: 90, beatsPerBar: 4,
             barChordIDs: ["Am", "C", "D", "F", "Am", "C", "E", "E"]),
        Song(id: "canon-d", title: "Canon in D", credit: "Pachelbel",
             bpm: 80, beatsPerBar: 4,
             barChordIDs: ["D", "A", "Bm", "F#m", "G", "D", "G", "A"]),
        Song(id: "folk-g", title: "Simple Folk Song", credit: "Original",
             bpm: 96, beatsPerBar: 4,
             barChordIDs: ["G", "G", "C", "G", "Em", "C", "D", "G"]),
    ]
}
