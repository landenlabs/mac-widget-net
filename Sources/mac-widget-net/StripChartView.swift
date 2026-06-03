// Copyright (c) 2026 LanDen Labs - Dennis Lang
import SwiftUI

struct StripChartView: View {
    let samples:       [Double]
    let peak:          Double
    var lineColor:     Color = .green
    var uploadSamples: [Double]? = nil
    var uploadColor:   Color = .orange

    var body: some View {
        Canvas { context, size in
            let effectivePeak = max(peak, 1)
            drawSeries(context: context, size: size,
                       samples: samples, peak: effectivePeak, color: lineColor)
            if let up = uploadSamples {
                drawSeries(context: context, size: size,
                           samples: up, peak: effectivePeak, color: uploadColor)
            }
        }
    }

    private func drawSeries(context: GraphicsContext, size: CGSize,
                            samples: [Double], peak: Double, color: Color) {
        guard samples.count > 1 else { return }
        let stepX = size.width / CGFloat(samples.count - 1)

        func pt(_ i: Int) -> CGPoint {
            CGPoint(
                x: CGFloat(i) * stepX,
                y: size.height * (1 - min(CGFloat(samples[i] / peak), 1))
            )
        }

        var fill = Path()
        fill.move(to: CGPoint(x: 0, y: size.height))
        fill.addLine(to: pt(0))
        for i in 1..<samples.count { fill.addLine(to: pt(i)) }
        fill.addLine(to: CGPoint(x: size.width, y: size.height))
        fill.closeSubpath()
        context.fill(fill, with: .color(color.opacity(0.20)))

        var line = Path()
        line.move(to: pt(0))
        for i in 1..<samples.count { line.addLine(to: pt(i)) }
        context.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: 1.5))
    }
}
