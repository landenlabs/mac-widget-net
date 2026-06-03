import SwiftUI

struct ContentView: View {
    @ObservedObject var monitor:  NetworkMonitor
    @ObservedObject var appState: AppState

    private var cfg:   WidgetConfig { appState.config }
    private var color: Color        { cfg.graphColor.color }

    // Shared y-scale so download and upload are comparable
    private var sharedPeak: Double {
        cfg.showUpload ? max(monitor.downloadPeak, monitor.uploadPeak) : monitor.downloadPeak
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            rateHeader

            ZStack(alignment: .topTrailing) {
                StripChartView(
                    samples:       monitor.downloadSamples,
                    peak:          sharedPeak,
                    lineColor:     color,
                    uploadSamples: cfg.showUpload ? monitor.uploadSamples : nil,
                    uploadColor:   .orange
                )
                .frame(height: cfg.graphHeight)

                Text(formatRate(sharedPeak))
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(color.opacity(0.40))
                    .padding([.top, .trailing], 2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(cfg.backgroundOpacity))
        )
        .frame(width: cfg.windowSize.width, height: cfg.windowSize.height)
    }

    // MARK: - Header

    private var rateHeader: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.down")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(color)
            Text(formatRate(monitor.currentDownload))
                .font(.system(size: 11, design: .monospaced).weight(.medium))
                .foregroundColor(color)

            if cfg.showUpload {
                Spacer()
                Image(systemName: "arrow.up")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.orange)
                Text(formatRate(monitor.currentUpload))
                    .font(.system(size: 11, design: .monospaced).weight(.medium))
                    .foregroundColor(.orange)
            }

            Spacer()

            Text(formatDuration(cfg.historySeconds))
                .font(.system(size: 8))
                .foregroundColor(.secondary.opacity(0.45))
        }
        .frame(height: WidgetConfig.headerHeight)
    }

    // MARK: - Formatting

    func formatRate(_ bytesPerSec: Double) -> String {
        switch cfg.units {
        case .auto:
            switch bytesPerSec {
            case 1_000_000...: return String(format: "%.1f MB/s", bytesPerSec / 1_000_000)
            case 1_000...:     return String(format: "%.1f KB/s", bytesPerSec / 1_000)
            default:           return String(format: "%.0f B/s",  bytesPerSec)
            }
        case .bytesPS:
            return String(format: "%.0f B/s",   bytesPerSec)
        case .kilobytesPS:
            return String(format: "%.1f KB/s",  bytesPerSec / 1_000)
        case .megabytesPS:
            return String(format: "%.2f MB/s",  bytesPerSec / 1_000_000)
        case .bitsPS:
            return String(format: "%.0f bps",   bytesPerSec * 8)
        case .kilobitsPS:
            return String(format: "%.1f Kbps",  bytesPerSec * 8 / 1_000)
        case .megabitsPS:
            return String(format: "%.2f Mbps",  bytesPerSec * 8 / 1_000_000)
        }
    }

    private func formatDuration(_ s: Double) -> String {
        Int(s) < 60 ? "\(Int(s))s" : "\(Int(s) / 60)m"
    }
}
