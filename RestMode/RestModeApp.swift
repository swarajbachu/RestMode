//
//  RestModeApp.swift
//  RestMode
//
//  Created by whizzy on 3600/04/25.
//

import SwiftUI
import UserNotifications
import AppKit // Import AppKit to access NSWindow properties

@main
struct RestModeApp: App {
    @StateObject private var manager = RestModeManager()
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    var body: some Scene {
        MenuBarExtra("RestMode", systemImage: "eyes") {
            MenuBarView()
                .environmentObject(manager)
        }
        .menuBarExtraStyle(.window)
        // Monitor isBreakActive to open/close and configure the overlay window
        .onChange(of: manager.isBreakActive) { oldValue, newValue in
            if newValue {
                openWindow(id: "break-overlay-window")
                // Try multiple times to configure the window
                let attempts = 5
                for attempt in 0..<attempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(attempt) * 0.1) {
                        configureOverlayWindow()
                    }
                }
            } else {
                dismissWindow(id: "break-overlay-window")
            }
        }

        // Define the full-screen break overlay window
        WindowGroup(id: "break-overlay-window") {
            BreakOverlayContainerView()
                .environmentObject(manager)
        }
        .windowStyle(.plain) // Borderless window
        .windowResizability(.contentSize) // Prevent resizing
        .defaultSize(width: NSScreen.main?.frame.width ?? 1920, height: NSScreen.main?.frame.height ?? 1080)
        .defaultPosition(.center)
    }

    // Function to configure the NSWindow properties for overlay behavior
    private func configureOverlayWindow() {
        guard let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "break-overlay-window" }) else {
             print("RestModeApp: Error - Could not find overlay window to configure. Available windows: \(NSApp.windows.count)")
             return
        }
        print("RestModeApp: Successfully found and configuring overlay window.")
        
        window.level = .screenSaver // Even higher level than .floating
        window.isMovable = false
        window.isMovableByWindowBackground = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        window.backgroundColor = NSColor(white: 0, alpha: 0.5) // Add a semi-transparent background
        window.hasShadow = false
        window.makeKeyAndOrderFront(nil)
        
        // Force the window to cover the entire screen
        if let screen = NSScreen.main {
            window.setFrame(screen.frame, display: true)
        }
    }
}

// New Container View for the overlay content
struct BreakOverlayContainerView: View {
    @EnvironmentObject var manager: RestModeManager

    var body: some View {
        ZStack {
            // Heavy blur effect
            Rectangle()
                .fill(.ultraThickMaterial.opacity(0.99)) // Almost fully opaque
                .background(.black.opacity(0.5)) // Additional darkening
                .ignoresSafeArea()

            // Optional: Add a solid color overlay to further reduce background visibility
            Rectangle()
                .fill(.black.opacity(0.3))
                .ignoresSafeArea()

            // Break content
            if manager.isBreakActive {
                BreakView()
                    .environmentObject(manager)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

