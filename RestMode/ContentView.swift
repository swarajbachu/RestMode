import SwiftUI
import BackgroundTasks
import UserNotifications

class RestModeManager: ObservableObject {
    @Published var isRestModeActive = false
    @Published var timeRemaining = 20 * 60
    @Published var nextBreakTime = Date().addingTimeInterval(3600)
    
    private var timer: Timer?
    
    init() {
        setupNotifications()
        scheduleNextBreak()
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func startBreak(duration: Int = 20 * 60) {
        isRestModeActive = true
        timeRemaining = duration
        startTimer()
    }
    
    func skipBreak() {
        isRestModeActive = false
        scheduleNextBreak()
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.skipBreak()
            }
        }
    }
    
    private func scheduleNextBreak() {
        nextBreakTime = Date().addingTimeInterval(3600)
        scheduleNotification()
        
        // Schedule the next automatic break
        DispatchQueue.main.asyncAfter(deadline: .now() + 3600) { [weak self] in
            self?.startBreak()
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a Break"
        content.body = "It's been an hour - time to rest your eyes!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "breakTime", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct ContentView: View {
    @StateObject private var manager = RestModeManager()
    
    var body: some View {
        ZStack {
            if manager.isRestModeActive {
                RestModeView(manager: manager)
                    .transition(.opacity)
            } else {
                NormalModeView(manager: manager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: manager.isRestModeActive)
    }
}

struct RestModeView: View {
    @ObservedObject var manager: RestModeManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Time to Rest")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text(timeString(from: manager.timeRemaining))
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Take a break")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            manager.startBreak(duration: 5 * 60)
                        }) {
                            Text("5 min")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            manager.startBreak(duration: 3600 * 60)
                        }) {
                            Text("3600 min")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            manager.skipBreak()
                        }) {
                            Text("Skip")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .statusBar(hidden: true)
        }
        .ignoresSafeArea()
    }
}

struct NormalModeView: View {
    @ObservedObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Next break in:")
                .font(.title2)
            
            Text(timeString(from: Int(manager.nextBreakTime.timeIntervalSince(Date()))))
                .font(.system(size: 40, weight: .bold))
            
            Button(action: {
                manager.startBreak()
            }) {
                Text("Start Break Now")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(3600)
            }
        }
    }
}

func timeString(from seconds: Int) -> String {
    let minutes = max(0, seconds) / 60
    let remainingSeconds = max(0, seconds) % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}

#Preview {
    ContentView()
}