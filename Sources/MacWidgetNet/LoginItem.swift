// Copyright (c) 2026 LanDen Labs - Dennis Lang
import Foundation
import ServiceManagement

/// Registers/unregisters the app as a login item via SMAppService.
///
/// SMAppService relaunches the app's own .app bundle at login — it only
/// works when the running binary is packaged inside a real bundle (see
/// `build_app.sh`). A bare SwiftPM executable has no bundle for the system
/// to relaunch, which previously caused the login item to fall back to
/// opening the binary in a foreground Terminal shell.
enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// True when the running binary is inside a real `.app` bundle (e.g.
    /// `/Applications/MacWidgetNet.app/Contents/MacOS/MacWidgetNet`), as
    /// opposed to a bare SwiftPM binary under `.build/`. SMAppService will
    /// happily "register" a bare binary too, but launchd then has nothing
    /// bundle-like to relaunch at login, so it falls back to running the
    /// executable attached to a foreground Terminal-style session that
    /// never closes. Gating registration here stops that bad state from
    /// being created again; see `build_app.sh`/`run.sh` for the two ways
    /// this binary gets launched.
    static var isRunningFromAppBundle: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    static func set(enabled: Bool) {
        if enabled && !isRunningFromAppBundle {
            NSLog("MacWidgetNet: refusing to register login item — not running from an installed .app bundle (build_app.sh). Run the app from /Applications instead.")
            return
        }
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("MacWidgetNet: failed to \(enabled ? "register" : "unregister") login item: \(error)")
        }
    }
}
