//
//  ChordProgression.swift
//  Preset chord progressions for change practice.
//

import Foundation

struct ChordProgression: Identifiable, Hashable {
    let id: String
    let name: String
    let chordIDs: [String]

    var chords: [Chord] {
        chordIDs.compactMap { id in ChordBank.all.first { $0.id == id } }
    }
}

enum ChordProgressions {
    static let all: [ChordProgression] = [
        ChordProgression(id: "g-c", name: "G – C", chordIDs: ["G", "C"]),
        ChordProgression(id: "g-c-d", name: "G – C – D", chordIDs: ["G", "C", "D"]),
        ChordProgression(id: "em-c-g-d", name: "Em – C – G – D", chordIDs: ["Em", "C", "G", "D"]),
        ChordProgression(id: "am-f-c-g", name: "Am – F – C – G", chordIDs: ["Am", "F", "C", "G"]),
        ChordProgression(id: "e-a", name: "E – A", chordIDs: ["E", "A"]),
        ChordProgression(id: "am-dm-e", name: "Am – Dm – E", chordIDs: ["Am", "Dm", "E"]),
    ]
}
