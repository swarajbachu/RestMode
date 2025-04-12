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
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 500),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .clear
        window.isMovableByWindowBackground = true
        window.center()
        window.setFrameAutosaveName("Settings")
        
        let contentView = SettingsView()
            .environmentObject(SettingsManager.shared)
        window.contentView = NSHostingView(rootView: contentView)
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

// Helper extension to find subviews
private extension NSView {
    func findSubview<T: NSView>(ofType type: T.Type) -> T? {
        if let splitView = self as? T {
            return splitView
        }
        for subview in subviews {
            if let found = subview.findSubview(ofType: type) {
                return found
            }
        }
        return nil
    }
} 
