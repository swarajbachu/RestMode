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
    
    private func formatTimeRemaining(_ seconds: Int) -> String {
        if seconds <= 0 {
            return "0s"
        }
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        return "\(minutes)m"
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(manager)
                .environmentObject(SettingsManager.shared)
                .frame(width: 240)
        } label: {
            HStack(spacing: 6) {
                let image: NSImage = {
                    let ratio = $0.size.height / $0.size.width
                    $0.size.height = 16
                    $0.size.width = 16 / ratio
                    return $0
                }(NSImage(named: Int(manager.timerState.nextBreakTime.timeIntervalSince(Date())) <= 60 ? "MenuBarIconEyesClosed" : "MenuBarIcon")!)
                
                Image(nsImage: image)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.primary)
                
                TimerDisplay(timerState: manager.timerState)
            }
            .padding(.horizontal, 2)
        }
        .menuBarExtraStyle(.menu)
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
        
        Settings {
            SettingsView()
                .environmentObject(SettingsManager.shared)
        }
        
        .onChange(of: manager.isBreakActive) { isActive in
            if isActive {
                overlayCoordinator.showOverlay(with: BreakOverlayContainerView()
                    .environmentObject(manager)
                    .environmentObject(SettingsManager.shared))
            } else {
                overlayCoordinator.hideOverlay()
            }
        }
    }
}
