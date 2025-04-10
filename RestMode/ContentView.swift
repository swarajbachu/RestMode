import SwiftUI
import UserNotifications

class RestModeManager: ObservableObject {
    @Published var isBreakActive = false
    @Published var timeRemaining = 20 * 60  // 20 minutes in seconds
    @Published var nextBreakTime: Date
    @Published var postponeOptions = true
    @Published var progress: Double = 0.0  // For progress indicator
    
    private var timer: Timer?
    private var workTimer: Timer?
    private let workDuration: TimeInterval = 3600 // 1 hour
    
    init() {
        self.nextBreakTime = Date().addingTimeInterval(workDuration)
        setupNotifications()
        startWorkTimer()
        
        // Start tracking progress immediately
        updateProgress()
    }
    
    private func updateProgress() {
        let totalTime = workDuration
        let remainingTime = nextBreakTime.timeIntervalSince(Date())
        progress = max(0, min(1, (totalTime - remainingTime) / totalTime))
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func startBreak() {
        DispatchQueue.main.async {
            self.isBreakActive = true
            self.timeRemaining = 20 * 60
            self.postponeOptions = true
            self.startBreakTimer()
            self.workTimer?.invalidate()
            
            // Show the break window
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Break Time" }) {
                window.makeKeyAndOrderFront(nil)
                window.level = .screenSaver
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary]
                window.toggleFullScreen(nil)
            }
        }
    }
    
    func postponeBreak(minutes: Int) {
        DispatchQueue.main.async {
            self.isBreakActive = false
            self.nextBreakTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
            
            // Close the break window
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Break Time" }) {
                if window.styleMask.contains(.fullScreen) {
                    window.toggleFullScreen(nil)
                }
                window.close()
            }
            
            self.startWorkTimer()
            self.scheduleNotification()
        }
    }
    
    func skipBreak() {
        postponeBreak(minutes: 60) // Skip to next hour
    }
    
    private func startBreakTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.skipBreak()
            }
        }
        
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func startWorkTimer() {
        workTimer?.invalidate()
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateProgress()
            if Date() >= self.nextBreakTime {
                self.startBreak()
            }
        }
        
        RunLoop.main.add(workTimer!, forMode: .common)
    }
    
    private func scheduleNextBreak() {
        nextBreakTime = Date().addingTimeInterval(workDuration)
        scheduleNotification()
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for an Eye Break"
        content.body = "Taking regular breaks helps reduce eye strain and maintain productivity."
        content.sound = .default
        
        let timeInterval = nextBreakTime.timeIntervalSince(Date())
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "breakTime", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct ContentView: View {
    @StateObject private var manager = RestModeManager()
    
    var body: some View {
        ZStack {
            if manager.isBreakActive {
                RestModeView(manager: manager)
                    .transition(.opacity)
            } else {
                NormalModeView(manager: manager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: manager.isBreakActive)
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
                            manager.startBreak()
                        }) {
                            Text("Take a Break")
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