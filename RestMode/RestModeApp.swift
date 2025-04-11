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
    
    var body: some Scene {
        MenuBarExtra("RestMode", systemImage: "eyes") {
            MenuBarView()
                .environmentObject(manager)
        }
        .menuBarExtraStyle(.window)
        .onChange(of: manager.isBreakActive) { oldValue, newValue in
            if newValue {
                overlayCoordinator.showOverlay(with: BreakOverlayContainerView()
                    .environmentObject(manager))
            } else {
                overlayCoordinator.hideOverlay()
            }
        }
    }
}

