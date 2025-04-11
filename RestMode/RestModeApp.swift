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
    
    var body: some Scene {
        WindowGroup(id: "break-window") {
            BreakView()
                .environmentObject(manager)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: NSScreen.main?.frame.width ?? 800, height: NSScreen.main?.frame.height ?? 600)
        .handlesExternalEvents(matching: Set(arrayLiteral: "restmode"))
        .commands {
            // Remove all default menu commands
            CommandGroup(replacing: .appInfo) { }
            CommandGroup(replacing: .textEditing) { }
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .systemServices) { }
            CommandGroup(replacing: .toolbar) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .windowSize) { }
            CommandGroup(replacing: .help) { }
        }
        
        MenuBarExtra("RestMode", systemImage: "eyes") {
            MenuBarView()
                .environmentObject(manager)
        }
        .menuBarExtraStyle(.window)
    }
    
    // init() {
    //     // Register URL scheme
    //     if let bundleIdentifier = Bundle.main.bundleIdentifier {
    //         LSSetDefaultHandlerForURLScheme("restmode" as CFString, bundleIdentifier as CFString)
    //     }
    // }
}

