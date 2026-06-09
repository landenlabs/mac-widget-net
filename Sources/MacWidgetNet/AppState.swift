// Copyright (c) 2026 LanDen Labs - Dennis Lang
import Foundation
import Combine

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var config: WidgetConfig {
        didSet { save() }
    }

    private let saveURL: URL

    private init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = support.appendingPathComponent("MacWidgetNet")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        saveURL = dir.appendingPathComponent("settings.json")

        if let data = try? Data(contentsOf: saveURL),
           let loaded = try? JSONDecoder().decode(WidgetConfig.self, from: data) {
            config = loaded
        } else {
            config = WidgetConfig()
        }
    }

    func updatePosition(x: Double, y: Double) {
        config.positionX = x
        config.positionY = y
        config.screenPositions[ScreenFingerprint.current] = ScreenPosition(x: x, y: y)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(config) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }
}
