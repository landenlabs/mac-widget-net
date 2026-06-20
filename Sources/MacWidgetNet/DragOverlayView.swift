// Copyright (c) 2026 LanDen Labs - Dennis Lang
import AppKit

final class DragOverlayView: NSView {
    var onMove: ((NSPoint) -> Void)?

    private var dragStart: NSPoint = .zero
    private var winStart:  NSPoint = .zero

    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .openHand)
    }

    override func mouseDown(with event: NSEvent) {
        dragStart = NSEvent.mouseLocation
        winStart  = window?.frame.origin ?? .zero
        NSCursor.closedHand.set()
    }

    override func mouseDragged(with event: NSEvent) {
        guard let win = window else { return }
        let loc       = NSEvent.mouseLocation
        let newOrigin = NSPoint(x: winStart.x + loc.x - dragStart.x,
                                y: winStart.y + loc.y - dragStart.y)
        win.setFrameOrigin(newOrigin)
        onMove?(newOrigin)
    }

    override func mouseUp(with event: NSEvent) {
        NSCursor.openHand.set()
        if let origin = window?.frame.origin {
            onMove?(origin)
        }
    }
}
