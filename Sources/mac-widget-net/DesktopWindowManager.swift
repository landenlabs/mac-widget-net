import AppKit
import SwiftUI
import Combine

final class DesktopWindowManager: NSObject {
    private var window:      NSWindow?
    private var dragOverlay: DragOverlayView?
    private let appState:    AppState
    private let monitor:     NetworkMonitor
    private var cancellables = Set<AnyCancellable>()

    private(set) var isDragging = false

    private let desktopLevel = NSWindow.Level(
        rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey(rawValue: 2)!)) + 1
    )

    init(appState: AppState, monitor: NetworkMonitor) {
        self.appState = appState
        self.monitor  = monitor
    }

    // MARK: - Setup / Teardown

    func setup() {
        let cfg  = appState.config
        let size = cfg.windowSize

        let win = NSWindow(
            contentRect: NSRect(x: cfg.effectiveX, y: cfg.effectiveY,
                                width: size.width, height: size.height),
            styleMask:   .borderless,
            backing:     .buffered,
            defer:       false
        )
        win.level                = desktopLevel
        win.backgroundColor      = .clear
        win.isOpaque             = false
        win.hasShadow            = false
        win.ignoresMouseEvents   = true
        win.isReleasedWhenClosed = false
        win.collectionBehavior   = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        win.delegate             = self

        let root = ContentView(monitor: monitor, appState: appState)
        win.contentViewController = NSHostingController(rootView: root)
        win.orderFront(nil)
        self.window = win

        // Resize when graphWidth / graphHeight change
        appState.$config
            .map { ($0.windowSize.width, $0.windowSize.height) }
            .removeDuplicates { $0 == $1 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (w, h) in
                self?.window?.setContentSize(NSSize(width: w, height: h))
            }
            .store(in: &cancellables)
    }

    func teardown() {
        disableDragMode()
        window?.close()
        window = nil
        cancellables.removeAll()
    }

    // MARK: - Drag Mode

    func toggleDragMode() {
        isDragging ? disableDragMode() : enableDragMode()
    }

    private func enableDragMode() {
        guard let win = window, let contentView = win.contentView else { return }
        isDragging = true

        win.level             = .floating
        win.ignoresMouseEvents = false

        let overlay = DragOverlayView(frame: contentView.bounds)
        overlay.autoresizingMask = [.width, .height]
        overlay.onMove = { [weak self] origin in
            self?.appState.updatePosition(x: origin.x, y: origin.y)
        }
        contentView.addSubview(overlay, positioned: .above, relativeTo: nil)
        dragOverlay = overlay
    }

    private func disableDragMode() {
        guard let win = window else { return }
        isDragging = false

        dragOverlay?.removeFromSuperview()
        dragOverlay = nil

        win.level             = desktopLevel
        win.ignoresMouseEvents = true

        if let origin = win.screen != nil ? Optional(win.frame.origin) : nil {
            appState.updatePosition(x: origin.x, y: origin.y)
        }
    }
}

// MARK: - NSWindowDelegate

extension DesktopWindowManager: NSWindowDelegate {
    func windowDidMove(_ notification: Notification) {
        guard isDragging, let win = window else { return }
        appState.updatePosition(x: win.frame.origin.x, y: win.frame.origin.y)
    }
}
