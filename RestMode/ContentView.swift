//
//  ContentView.swift
//  RestMode
//
//  Created by whizzy on 10/04/25.
//

import SwiftUI
import BackgroundTasks

struct ContentView: View {
    @State private var timeRemaining = 20 * 60 // 20 minutes in seconds
    @State private var isRestModeActive = false
    @State private var nextBreakTime = Date().addingTimeInterval(3600) // 1 hour from now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let hourlyTimer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if isRestModeActive {
                    Text("Time to Rest")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Take a break")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            timeRemaining = 5 * 60
                        }) {
                            Text("5 min")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            timeRemaining = 10 * 60
                        }) {
                            Text("10 min")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            isRestModeActive = false
                            nextBreakTime = Date().addingTimeInterval(3600)
                        }) {
                            Text("Skip")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top)
                } else {
                    VStack(spacing: 20) {
                        Text("Next break in:")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(timeString(from: Int(nextBreakTime.timeIntervalSince(Date()))))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        
                        Button(action: {
                            isRestModeActive = true
                            timeRemaining = 20 * 60
                        }) {
                            Text("Start Break Now")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if isRestModeActive && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                isRestModeActive = false
                nextBreakTime = Date().addingTimeInterval(3600)
            }
        }
        .onReceive(hourlyTimer) { _ in
            if !isRestModeActive {
                isRestModeActive = true
                timeRemaining = 20 * 60
            }
        }
        .onAppear {
            setupBackgroundTasks()
        }
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func setupBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.restmode.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        scheduleBackgroundRefresh()
    }
    
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.restmode.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        if !isRestModeActive {
            isRestModeActive = true
            timeRemaining = 20 * 60
        }
        
        task.setTaskCompleted(success: true)
        scheduleBackgroundRefresh()
    }
}

#Preview {
    ContentView()
}
