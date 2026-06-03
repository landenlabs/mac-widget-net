// Copyright (c) 2026 LanDen Labs - Dennis Lang
import Foundation
import AppKit
import SwiftUI

// MARK: - Enums

enum TrafficUnits: String, Codable, CaseIterable, Identifiable {
    case auto        = "Auto"
    case bytesPS     = "B/s"
    case kilobytesPS = "KB/s"
    case megabytesPS = "MB/s"
    case bitsPS      = "bps"
    case kilobitsPS  = "Kbps"
    case megabitsPS  = "Mbps"
    var id: String { rawValue }
}

enum GraphColor: String, Codable, CaseIterable, Identifiable {
    case green  = "Green"
    case cyan   = "Cyan"
    case blue   = "Blue"
    case orange = "Orange"
    case yellow = "Yellow"
    case white  = "White"
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .green:  return .green
        case .cyan:   return .cyan
        case .blue:   return .blue
        case .orange: return .orange
        case .yellow: return .yellow
        case .white:  return .white
        }
    }
}

// MARK: - ScreenPosition

struct ScreenPosition: Codable, Equatable {
    var x: Double
    var y: Double
}

// MARK: - ScreenFingerprint

enum ScreenFingerprint {
    static var current: String {
        NSScreen.screens
            .sorted { $0.frame.minX < $1.frame.minX || ($0.frame.minX == $1.frame.minX && $0.frame.minY < $1.frame.minY) }
            .map { "\(Int($0.frame.width))x\(Int($0.frame.height))@\(Int($0.frame.origin.x)),\(Int($0.frame.origin.y))" }
            .joined(separator: "|")
    }
}

// MARK: - WidgetConfig

struct WidgetConfig: Codable {
    var sampleInterval:    Double     = 1.0
    var historySeconds:    Double     = 60.0
    var graphWidth:        Double     = 300.0
    var graphHeight:       Double     = 80.0
    var backgroundOpacity: Double     = 0.15
    var units:             TrafficUnits = .auto
    var showUpload:        Bool       = false
    var graphColor:        GraphColor = .green
    var positionX:         Double     = 40.0
    var positionY:         Double     = 400.0
    var screenPositions:   [String: ScreenPosition] = [:]

    // MARK: Computed

    var maxSamples: Int {
        max(10, Int((historySeconds / sampleInterval).rounded()))
    }

    static let headerHeight: Double = 20
    static let verticalPadding: Double = 16   // 8 top + 8 bottom

    var windowSize: CGSize {
        CGSize(
            width:  graphWidth,
            height: graphHeight + WidgetConfig.headerHeight + WidgetConfig.verticalPadding + 4
        )
    }

    var effectiveX: Double { screenPositions[ScreenFingerprint.current]?.x ?? positionX }
    var effectiveY: Double { screenPositions[ScreenFingerprint.current]?.y ?? positionY }

    // MARK: Codable with forward-compatible defaults

    enum CodingKeys: String, CodingKey {
        case sampleInterval, historySeconds, graphWidth, graphHeight
        case backgroundOpacity, units, showUpload, graphColor
        case positionX, positionY, screenPositions
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sampleInterval    = (try? c.decode(Double.self,       forKey: .sampleInterval))    ?? 1.0
        historySeconds    = (try? c.decode(Double.self,       forKey: .historySeconds))    ?? 60.0
        graphWidth        = (try? c.decode(Double.self,       forKey: .graphWidth))        ?? 300.0
        graphHeight       = (try? c.decode(Double.self,       forKey: .graphHeight))       ?? 80.0
        backgroundOpacity = (try? c.decode(Double.self,       forKey: .backgroundOpacity)) ?? 0.15
        units             = (try? c.decode(TrafficUnits.self, forKey: .units))             ?? .auto
        showUpload        = (try? c.decode(Bool.self,         forKey: .showUpload))        ?? false
        graphColor        = (try? c.decode(GraphColor.self,   forKey: .graphColor))        ?? .green
        positionX         = (try? c.decode(Double.self,       forKey: .positionX))         ?? 40.0
        positionY         = (try? c.decode(Double.self,       forKey: .positionY))         ?? 400.0
        screenPositions   = (try? c.decode([String: ScreenPosition].self, forKey: .screenPositions)) ?? [:]
    }

    init() {}
}
