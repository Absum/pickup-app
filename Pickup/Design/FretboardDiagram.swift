//
//  FretboardDiagram.swift
//  Compact fretboard chart. Takes one or more fret positions, so it renders
//  both single fretted notes (lessons) and full chord shapes (chord bank).
//  String 0 = low E on the left … string 5 = high e on the right.
//

import SwiftUI

struct FretboardDiagram: View {
    var positions: [FretPosition]
    var mutedStrings: [Int] = []
    var maxFret: Int = 4
    var tint: Color = Theme.teal

    var body: some View {
        Canvas { ctx, size in
            let cols = 6
            let leftPad: CGFloat = 18, rightPad: CGFloat = 18
            let topPad: CGFloat = 22, bottomPad: CGFloat = 8
            let w = size.width - leftPad - rightPad
            let h = size.height - topPad - bottomPad
            let colGap = w / CGFloat(cols - 1)
            let rowGap = h / CGFloat(maxFret)

            // Nut
            var nut = Path()
            nut.move(to: CGPoint(x: leftPad, y: topPad))
            nut.addLine(to: CGPoint(x: leftPad + w, y: topPad))
            ctx.stroke(nut, with: .color(.white.opacity(0.85)), lineWidth: 3)

            // Frets
            for f in 1...maxFret {
                let y = topPad + rowGap * CGFloat(f)
                var p = Path()
                p.move(to: CGPoint(x: leftPad, y: y))
                p.addLine(to: CGPoint(x: leftPad + w, y: y))
                ctx.stroke(p, with: .color(.white.opacity(0.16)), lineWidth: 1)
            }
            // Strings
            for s in 0..<cols {
                let x = leftPad + colGap * CGFloat(s)
                var p = Path()
                p.move(to: CGPoint(x: x, y: topPad))
                p.addLine(to: CGPoint(x: x, y: topPad + h))
                ctx.stroke(p, with: .color(.white.opacity(0.22)), lineWidth: 1)
            }
            // Markers
            for pos in positions where pos.string >= 0 && pos.string < cols {
                let x = leftPad + colGap * CGFloat(pos.string)
                if pos.fret == 0 {
                    // Open-string ring above the nut.
                    let r: CGFloat = 6
                    let rect = CGRect(x: x - r, y: topPad - 15 - r, width: 2 * r, height: 2 * r)
                    ctx.stroke(Path(ellipseIn: rect), with: .color(tint), lineWidth: 2)
                } else if pos.fret <= maxFret {
                    let y = topPad + rowGap * (CGFloat(pos.fret) - 0.5)
                    let r: CGFloat = 10
                    let rect = CGRect(x: x - r, y: y - r, width: 2 * r, height: 2 * r)
                    ctx.fill(Path(ellipseIn: rect), with: .color(tint))
                }
            }

            // Muted strings: an X above the nut.
            for s in mutedStrings where s >= 0 && s < cols {
                let x = leftPad + colGap * CGFloat(s)
                let y = topPad - 15
                let d: CGFloat = 5
                var p = Path()
                p.move(to: CGPoint(x: x - d, y: y - d)); p.addLine(to: CGPoint(x: x + d, y: y + d))
                p.move(to: CGPoint(x: x - d, y: y + d)); p.addLine(to: CGPoint(x: x + d, y: y - d))
                ctx.stroke(p, with: .color(.white.opacity(0.5)), lineWidth: 2)
            }
        }
    }
}
