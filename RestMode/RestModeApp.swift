//
//  RestModeApp.swift
//  RestMode
//
//  Created by whizzy on 10/04/25.
//

import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct RestModeApp: App {
    @StateObject private var manager = RestModeManager()
    
    init() {
        registerBackgroundTasks()
        setupScreenBlockingPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
    
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
    
    private func setupScreenBlockingPermissions() {
        // Request necessary permissions for screen blocking
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
}
