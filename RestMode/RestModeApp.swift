//
//  RestModeApp.swift
//  RestMode
//
//  Created by whizzy on 3600/04/25.
//

import SwiftUI

@main
struct RestModeApp: App {
    @StateObject private var manager = RestModeManager()
    @StateObject private var overlayCoordinator = OverlayWindowCoordinator()
    @StateObject private var settingsWindowManager = SettingsWindowManager()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(manager)
                .environmentObject(SettingsManager.shared)
        } label: {
            // This uses your custom Cloud image as a template image
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 18
                $0.size.width = 18 / ratio
                return $0
            }(NSImage(named: Int(manager.nextBreakTime.timeIntervalSince(Date())) <= 60 ? "MenuBarIconEyesClosed" : "MenuBarIcon")!)
            
            Image(nsImage: image)
        }
        .menuBarExtraStyle(.window)
        .onChange(of: manager.isBreakActive) { oldValue, newValue in
            if newValue {
                overlayCoordinator.showOverlay(with: BreakOverlayContainerView()
                    .environmentObject(manager)
                    .environmentObject(SettingsManager.shared))
            } else {
                overlayCoordinator.hideOverlay()
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(SettingsManager.shared)
        }
        
        // Add global keyboard shortcuts
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Start Break Now") {
                    manager.startBreak()
                }
                .keyboardShortcut("b", modifiers: .command)
                
                Button("Postpone 5 Minutes") {
                    manager.postponeBreak(minutes: 5)
                }
                .keyboardShortcut("p", modifiers: .command)
                
                Button("Skip to Next Hour") {
                    manager.skipBreak()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Settings...") {
                    settingsWindowManager.showSettingsWindow()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
