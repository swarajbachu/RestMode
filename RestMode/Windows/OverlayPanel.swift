import SwiftUI
import AppKit

class OverlayPanel: NSPanel {
    static func create() -> OverlayPanel {
        let panel = OverlayPanel(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Configure panel properties
        panel.isFloatingPanel = true
        panel.level = .statusBar + 1 // Above the menu bar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = false
        panel.isMovable = false
        panel.isMovableByWindowBackground = false
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        
        
        // Ensure it covers the full screen
        if let screen = NSScreen.main {
            panel.setFrame(screen.frame, display: true)
        }
        
        return panel
    }
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
} 