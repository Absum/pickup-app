//
//  ChordsView.swift
//  The Chords tab — a chord bank you can browse and practice.
//

import SwiftUI

struct ChordsView: View {
    @State private var activeChord: Chord?

    private let columns = [GridItem(.flexible(), spacing: 14),
                           GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            ArcticBackground()
            VStack(spacing: 0) {
                header.padding(.top, 12)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(ChordBank.all) { chord in
                            Button { activeChord = chord } label: { chordCard(chord) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                }
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $activeChord) { chord in
            ChordPracticeView(chord: chord) { activeChord = nil }
        }
        .onAppear {
            #if DEBUG
            if let id = ProcessInfo.processInfo.environment["PICKUP_CHORD"],
               let chord = ChordBank.all.first(where: { $0.id == id }) {
                activeChord = chord
            }
            #endif
        }
    }

    private var header: some View {
        VStack(spacing: 3) {
            Text("PICKUP").font(Theme.display(22)).tracking(10).foregroundStyle(.white)
            Text("CHORDS").font(Theme.light(12)).tracking(4).foregroundStyle(Theme.frost.opacity(0.6))
        }
    }

    private func chordCard(_ chord: Chord) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(chord.name).font(Theme.display(26)).foregroundStyle(.white)
                Spacer()
                Text(chord.quality).font(Theme.body(12)).foregroundStyle(Theme.frost.opacity(0.6))
            }
            FretboardDiagram(positions: chord.positions, mutedStrings: chord.mutedStrings)
                .frame(height: 110)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
    }
}
