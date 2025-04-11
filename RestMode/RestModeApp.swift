//
//  RestModeApp.swift
//  RestMode
//
//  Created by whizzy on 3600/04/25.
//

import SwiftUI
import UserNotifications

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
        // Monitor isBreakActive to open/close the window
        .onChange(of: manager.isBreakActive) { oldValue, newValue in
            if newValue {
                openWindow(id: "break-window")
            } else {
                // Check if the window exists before trying to dismiss
                // This avoids potential issues if the window was closed manually
                dismissWindow(id: "break-window")
            }
        }
        
        // Define the break window
        WindowGroup(id: "break-window") {
            BreakView()
                .environmentObject(manager)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: NSScreen.main?.frame.width ?? 800, height: NSScreen.main?.frame.height ?? 600)
        .defaultPosition(.center)
        .commands {
            // Remove all default menu commands
            CommandGroup(replacing: .textEditing) { }
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .toolbar) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .windowSize) { }
            CommandGroup(replacing: .help) { }
        }
    }
}

