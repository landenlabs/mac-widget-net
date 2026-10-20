// Copyright (c) 2026 LanDen Labs - Dennis Lang
import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState

    private var cfg: Binding<WidgetConfig> {
        Binding(get: { self.appState.config },
                set: { self.appState.config = $0 })
    }

    var body: some View {
        Form {
            Section("Sampling") {
                Picker("Sample interval", selection: cfg.sampleInterval) {
                    Text("0.5 s").tag(0.5)
                    Text("1 s").tag(1.0)
                    Text("2 s").tag(2.0)
                    Text("5 s").tag(5.0)
                    Text("10 s").tag(10.0)
                }
                .pickerStyle(.menu)

                Picker("History window", selection: cfg.historySeconds) {
                    Text("30 s").tag(30.0)
                    Text("1 min").tag(60.0)
                    Text("2 min").tag(120.0)
                    Text("5 min").tag(300.0)
                    Text("10 min").tag(600.0)
                }
                .pickerStyle(.menu)

                Text("\(appState.config.maxSamples) samples — shows last \(formatDuration(appState.config.historySeconds))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Units & Traffic") {
                Picker("Display units", selection: cfg.units) {
                    ForEach(TrafficUnits.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.menu)

                Toggle("Show upload traffic", isOn: cfg.showUpload)
            }

            Section("Graph Size") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Width: \(Int(appState.config.graphWidth)) pt")
                        .font(.caption).foregroundColor(.secondary)
                    Slider(value: cfg.graphWidth, in: 150...600, step: 10)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Height: \(Int(appState.config.graphHeight)) pt")
                        .font(.caption).foregroundColor(.secondary)
                    Slider(value: cfg.graphHeight, in: 40...200, step: 5)
                }
            }

            Section("Appearance") {
                Picker("Line color", selection: cfg.graphColor) {
                    ForEach(GraphColor.allCases) { c in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(c.color)
                                .frame(width: 10, height: 10)
                            Text(c.rawValue)
                        }
                        .tag(c)
                    }
                }
                .pickerStyle(.menu)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Background opacity: \(Int(appState.config.backgroundOpacity * 100))%")
                        .font(.caption).foregroundColor(.secondary)
                    Slider(value: cfg.backgroundOpacity, in: 0...0.6, step: 0.05)
                }
            }

            Section("System") {
                LaunchAtLoginToggle()
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 300, minHeight: 440)
    }

    private func formatDuration(_ s: Double) -> String {
        Int(s) < 60 ? "\(Int(s)) sec" : "\(Int(s) / 60) min"
    }
}

/// "Launch at login" checkbox shared by the settings panes. Holds its own
/// state so the checkmark refreshes after toggling.
struct LaunchAtLoginToggle: View {
    @State private var enabled = LoginItem.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("Launch at login", isOn: Binding(
                get: { enabled },
                set: { LoginItem.set(enabled: $0); enabled = LoginItem.isEnabled }
            ))
            .disabled(!LoginItem.isRunningFromAppBundle)
            if !LoginItem.isRunningFromAppBundle {
                Text("Only available when running the installed app from /Applications.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
