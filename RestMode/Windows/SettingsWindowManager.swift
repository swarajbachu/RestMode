import SwiftUI

class SettingsWindowManager: ObservableObject {
    private var settingsWindow: NSWindow?
    
    func showSettingsWindow() {
        if let existingWindow = settingsWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Settings"
        window.center()
        window.setFrameAutosaveName("Settings")
        window.contentView = NSHostingView(rootView: SettingsView()
            .environmentObject(SettingsManager.shared))
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow = window
        
        // Clean up when window closes
        window.isReleasedWhenClosed = false
        window.delegate = WindowDelegate { [weak self] in
            self?.settingsWindow = nil
        }
    }
}

private class WindowDelegate: NSObject, NSWindowDelegate {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
} 