import SwiftUI
import UserNotifications

class RestModeManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isBreakActive = false
    @Published var timeRemaining = 20 * 60  // 20 minutes in seconds
    @Published var nextBreakTime: Date
    @Published var postponeOptions = true
    @Published var progress: Double = 0.0
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var workTimer: Timer?
    private let workDuration: TimeInterval = 3600 // 1 hour
    private var isCleaningUp = false
    private let serialQueue = DispatchQueue(label: "com.restmode.serial", qos: .userInteractive)
    
    // MARK: - Initialization
    init() {
        print("RestModeManager: Initializing")
        self.nextBreakTime = Date().addingTimeInterval(workDuration)
        setupNotifications()
        startWorkTimer()
        updateProgress()
    }
    
    // MARK: - Public Methods
    func startBreak() {
        print("RestModeManager: Starting break")
        guard !isCleaningUp else {
            print("RestModeManager: Cannot start break while cleaning up")
            return
        }
        
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Stop existing timers
            self.stopTimers()
            
            // Update state
            DispatchQueue.main.async {
                self.isBreakActive = true
                self.timeRemaining = 20 * 60
                self.postponeOptions = true
                self.startBreakTimer()
                
                // Open break window using URL scheme
                if let url = URL(string: "restmode://break") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    func postponeBreak(minutes: Int) {
        print("RestModeManager: Postponing break by \(minutes) minutes")
        guard !isCleaningUp else {
            print("RestModeManager: Cannot postpone break while cleaning up")
            return
        }
        
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Stop break timer
            self.timer?.invalidate()
            self.timer = nil
            
            // Update state
            DispatchQueue.main.async {
                self.isBreakActive = false
                self.nextBreakTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
                self.startWorkTimer()
                self.scheduleNotification()
            }
        }
    }
    
    func skipBreak() {
        print("RestModeManager: Skipping break")
        postponeBreak(minutes: 60)
    }
    
    func cleanup() {
        print("RestModeManager: Starting cleanup")
        guard !isCleaningUp else {
            print("RestModeManager: Already cleaning up")
            return
        }
        
        isCleaningUp = true
        
        serialQueue.sync {
            stopTimers()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        print("RestModeManager: Cleanup completed")
    }
    
    // MARK: - Private Methods
    private func updateProgress() {
        let totalTime = workDuration
        let remainingTime = nextBreakTime.timeIntervalSince(Date())
        progress = max(0, min(1, (totalTime - remainingTime) / totalTime))
    }
    
    private func setupNotifications() {
        print("RestModeManager: Setting up notifications")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            if granted {
                print("RestModeManager: Notification permission granted")
                self?.scheduleNotification()
            }
        }
    }
    
    private func startBreakTimer() {
        print("RestModeManager: Starting break timer")
        timer?.invalidate()
        timer = nil
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.skipBreak()
            }
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func startWorkTimer() {
        print("RestModeManager: Starting work timer")
        workTimer?.invalidate()
        workTimer = nil
        
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateProgress()
            if Date() >= self.nextBreakTime {
                self.startBreak()
            }
        }
        
        if let workTimer = workTimer {
            RunLoop.main.add(workTimer, forMode: .common)
        }
    }
    
    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        workTimer?.invalidate()
        workTimer = nil
    }
    
    private func scheduleNotification() {
        print("RestModeManager: Scheduling notification")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Time for an Eye Break"
        content.body = "Taking regular breaks helps reduce eye strain and maintain productivity."
        content.sound = .default
        
        let timeInterval = nextBreakTime.timeIntervalSince(Date())
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "breakTime", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    deinit {
        print("RestModeManager: Deinitializing")
        cleanup()
    }
} 