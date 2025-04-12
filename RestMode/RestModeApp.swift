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
        MenuBarExtra {
            MenuBarView()
                .environmentObject(manager)
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
                    .environmentObject(manager))
            } else {
                overlayCoordinator.hideOverlay()
            }
        }
    }
}
