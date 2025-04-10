//
//  RestModeApp.swift
//  RestMode
//
//  Created by whizzy on 3600/04/25.
//

import SwiftUI
#if !os(macOS)
import BackgroundTasks
#endif
import UserNotifications

@main
struct RestModeApp: App {
    @StateObject private var manager = RestModeManager()
    
    var body: some Scene {
        MenuBarExtra("RestMode", systemImage: "timer") {
            MenuBarView()
                .environmentObject(manager)
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup("Break Time") {
            BreakView()
                .environmentObject(manager)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: NSScreen.main?.frame.width ?? 800, height: NSScreen.main?.frame.height ?? 600)
    }
    
    init() {
        #if !os(macOS)
        registerBackgroundTasks()
        #endif
        setupNotifications()
    }
    
    #if !os(macOS)
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.restmode.refresh", using: nil) { task in
            handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        scheduleNextBackgroundTask()
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Ensure the task runs for enough time
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Schedule the next background task
        scheduleNextBackgroundTask()
        
        // Start the break if needed
        DispatchQueue.main.async {
            if !manager.isRestModeActive {
                manager.startBreak()
            }
        }
        
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleNextBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.restmode.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // Schedule for 1 hour from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    #endif
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "eyes")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    Text("Rest Time")
                        .font(.headline)
                    Spacer()
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: 200 * manager.progress, height: 4)
                }
                
                HStack {
                    Text(timeString(from: Int(manager.nextBreakTime.timeIntervalSince(Date()))))
                        .font(.system(.body, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("until break")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            // Actions
            VStack(spacing: 0) {
                MenuButton(
                    title: "Start Break Now",
                    icon: "play.circle.fill",
                    color: .blue
                ) {
                    manager.startBreak()
                }
                
                MenuButton(
                    title: "Postpone 5 Minutes",
                    icon: "clock.arrow.circlepath",
                    color: .orange
                ) {
                    manager.postponeBreak(minutes: 5)
                }
                
                MenuButton(
                    title: "Skip to Next Hour",
                    icon: "forward.circle.fill",
                    color: .red
                ) {
                    manager.skipBreak()
                }
            }
            
            Divider()
            
            // Footer
            MenuButton(
                title: "Quit RestMode",
                icon: "power",
                color: .secondary
            ) {
                NSApplication.shared.terminate(nil)
            }
        }
        .frame(width: 240)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

struct BreakView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    Color(colorScheme == .dark ? .black : .white)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // Top section with timer
                VStack(spacing: 25) {
                    ZStack {
                        // Timer circle
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(manager.timeRemaining) / (20 * 60))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 8) {
                            Text(timeString(from: manager.timeRemaining))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.primary)
                            
                            Text("remaining")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Text("Time to Rest Your Eyes")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Look at something 20 feet away\nto reduce eye strain")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                if manager.postponeOptions {
                    // Bottom section with options
                    VStack(spacing: 16) {
                        Text("Not a good time?")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            ActionButton(
                                title: "5 min",
                                icon: "clock",
                                color: .orange
                            ) {
                                manager.postponeBreak(minutes: 5)
                            }
                            
                            ActionButton(
                                title: "10 min",
                                icon: "clock.arrow.circlepath",
                                color: .blue
                            ) {
                                manager.postponeBreak(minutes: 10)
                            }
                            
                            ActionButton(
                                title: "Skip",
                                icon: "forward.end.fill",
                                color: .red
                            ) {
                                manager.skipBreak()
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .padding(40)
        }
        .onAppear {
            setupFullScreenWindow()
        }
    }
    
    private func setupFullScreenWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Break Time" }) {
                window.level = .screenSaver
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary]
                window.toggleFullScreen(nil)
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.headline)
            }
            .frame(width: 100)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
