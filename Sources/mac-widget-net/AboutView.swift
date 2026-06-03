import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
                .padding(.top, 8)

            Text("Network Traffic Widget")
                .font(.title2.weight(.semibold))

            Text("Version \(appVersion)")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            Text("A lightweight desktop wallpaper widget that displays real-time network download and upload traffic as a scrolling strip chart.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)

            Divider()

            Text("© 2026 LanDen Labs")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .padding(24)
        .frame(width: 320)
    }
}
