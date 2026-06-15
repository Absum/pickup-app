//
//  FretboardDiagram.swift
//  Compact fretboard chart. Renders open chords (nut at top) and movable shapes
//  up the neck (auto-windowed with a base-fret label + barre bar). Takes one or
//  more positions, so it serves single fretted notes and full chord shapes.
//  String 0 = low E on the left … string 5 = high e on the right.
//

import SwiftUI

struct FretboardDiagram: View {
    var positions: [FretPosition]
    var mutedStrings: [Int] = []
    var barre: Barre? = nil
    var fretCount: Int = 4
    var tint: Color = Theme.teal

    private let markerOutline = Color(hex: 0x0A1F27)

    var body: some View {
        Canvas { ctx, size in
            let cols = 6
            let leftPad: CGFloat = 30, rightPad: CGFloat = 16
            let topPad: CGFloat = 24, bottomPad: CGFloat = 10
            let w = size.width - leftPad - rightPad
            let h = size.height - topPad - bottomPad
            let colGap = w / CGFloat(cols - 1)
            let rowGap = h / CGFloat(fretCount)
            // Dot radius scales with cell size, so the dot-to-grid ratio is the
            // same in the small listing cards and the full-screen practice view.
            let r = min(rowGap, colGap) * 0.30
            func x(_ s: Int) -> CGFloat { leftPad + colGap * CGFloat(s) }

            let frettedFrets = positions.filter { $0.fret > 0 }.map { $0.fret }
            let maxFret = frettedFrets.max() ?? 0
            let isOpen = maxFret <= fretCount
            let firstFret = isOpen ? 1 : (frettedFrets.min() ?? 1)

            // Top line: thick nut (open) or thin line + "Nfr" base label.
            var top = Path()
            top.move(to: CGPoint(x: leftPad, y: topPad))
            top.addLine(to: CGPoint(x: leftPad + w, y: topPad))
            ctx.stroke(top, with: .color(.white.opacity(isOpen ? 0.9 : 0.4)),
                       lineWidth: isOpen ? 3 : 1)
            if !isOpen {
                ctx.draw(Text("\(firstFret)fr")
                            .font(Theme.body(12))
                            .foregroundColor(Theme.frost.opacity(0.8)),
                         at: CGPoint(x: leftPad - 9, y: topPad + rowGap * 0.5), anchor: .trailing)
            }

            for f in 1...fretCount {
                let y = topPad + rowGap * CGFloat(f)
                var p = Path()
                p.move(to: CGPoint(x: leftPad, y: y))
                p.addLine(to: CGPoint(x: leftPad + w, y: y))
                ctx.stroke(p, with: .color(.white.opacity(0.22)), lineWidth: 1)
            }
            for s in 0..<cols {
                var p = Path()
                p.move(to: CGPoint(x: x(s), y: topPad))
                p.addLine(to: CGPoint(x: x(s), y: topPad + h))
                ctx.stroke(p, with: .color(.white.opacity(0.28)), lineWidth: 1)
            }

            // Barre bar (under the dots), spanning its strings at its fret row.
            if let barre {
                let row = barre.fret - firstFret
                if row >= 0 && row < fretCount {
                    let y = topPad + rowGap * (CGFloat(row) + 0.5)
                    let x1 = x(barre.fromString) - r * 0.6
                    let x2 = x(barre.toString) + r * 0.6
                    let bar = CGRect(x: x1, y: y - r * 0.9, width: x2 - x1, height: r * 1.8)
                    ctx.fill(Path(roundedRect: bar, cornerRadius: r * 0.9), with: .color(tint))
                }
            }

            // Markers
            for pos in positions where pos.string >= 0 && pos.string < cols {
                if pos.fret == 0 {
                    if isOpen {
                        let ring = CGRect(x: x(pos.string) - r * 0.7, y: topPad - 14 - r * 0.7,
                                          width: r * 1.4, height: r * 1.4)
                        ctx.stroke(Path(ellipseIn: ring), with: .color(tint), lineWidth: 2)
                    }
                } else {
                    if let barre, pos.fret == barre.fret,
                       pos.string >= barre.fromString, pos.string <= barre.toString { continue }
                    let row = pos.fret - firstFret
                    if row >= 0 && row < fretCount {
                        let y = topPad + rowGap * (CGFloat(row) + 0.5)
                        let dot = CGRect(x: x(pos.string) - r, y: y - r, width: 2 * r, height: 2 * r)
                        ctx.fill(Path(ellipseIn: dot), with: .color(tint))
                        ctx.stroke(Path(ellipseIn: dot), with: .color(markerOutline.opacity(0.55)), lineWidth: 1.5)
                    }
                }
            }

            // Muted strings: an X above the nut.
            for s in mutedStrings where s >= 0 && s < cols {
                let cx = x(s), cy = topPad - 14
                let d = r * 0.7
                var p = Path()
                p.move(to: CGPoint(x: cx - d, y: cy - d)); p.addLine(to: CGPoint(x: cx + d, y: cy + d))
                p.move(to: CGPoint(x: cx - d, y: cy + d)); p.addLine(to: CGPoint(x: cx + d, y: cy - d))
                ctx.stroke(p, with: .color(.white.opacity(0.5)), lineWidth: 2)
            }
        }
    }
}
