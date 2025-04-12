import SwiftUI
import UserNotifications
import Combine

class RestModeManager: ObservableObject {

    // MARK: - Published Properties
    @Published var isBreakActive = false
    @Published var timeRemaining = 20
    @Published var nextBreakTime: Date
    @Published var postponeOptions = true
    @Published var progress: Double = 0.0
    @Published private(set) var completedBreaks = 0
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var workTimer: Timer?
    private var isCleaningUp = false
    private let serialQueue = DispatchQueue(label: "com.restmode.serial", qos: .userInteractive)
    private let settings: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(settings: SettingsManager = .shared) {
        print("RestModeManager: Initializing")
        self.settings = settings
        self.nextBreakTime = Date().addingTimeInterval(TimeInterval(settings.workModeDuration * 60))
        
        setupNotifications()
        if settings.startTimerOnLaunch {
            startWorkTimer()
        }
        updateProgress()
        
        // Observe settings changes
        observeSettings()
    }
    
    // MARK: - Settings Observation
    private func observeSettings() {
        // Observe work mode duration changes
        settings.$workModeDuration
            .sink { [weak self] newDuration in
                guard let self = self else { return }
                if !self.isBreakActive {
                    self.resetWorkTimer(withDuration: newDuration)
                }
            }
            .store(in: &cancellables)
        
        // Observe short break duration changes
        settings.$shortBreakDuration
            .sink { [weak self] newDuration in
                guard let self = self, self.isBreakActive else { return }
                // Only update if we're in a short break
                if self.timeRemaining <= self.settings.shortBreakDuration {
                    self.timeRemaining = newDuration
                }
            }
            .store(in: &cancellables)
        
        // Observe long break duration changes
        settings.$longBreakDuration
            .sink { [weak self] newDuration in
                guard let self = self, self.isBreakActive else { return }
                // Only update if we're in a long break
                if self.timeRemaining > self.settings.shortBreakDuration {
                    self.timeRemaining = newDuration
                }
            }
            .store(in: &cancellables)
            
        // Observe hide skip button setting
        settings.$hideSkipButton
            .sink { [weak self] hideSkip in
                guard let self = self else { return }
                self.postponeOptions = !hideSkip
            }
            .store(in: &cancellables)
    }
    
    private func resetWorkTimer(withDuration duration: Int) {
        stopTimers()
        nextBreakTime = Date().addingTimeInterval(TimeInterval(duration * 60))
        updateProgress()
        startWorkTimer()
        scheduleNotification()
    }
    
    // MARK: - Timer Management
    private func startWorkTimer() {
        print("RestModeManager: Starting work timer")
        workTimer?.invalidate()
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateProgress()
            
            // Check for idle time if enabled
            if self.settings.pauseOnIdle {
                let idleTime = NSEvent.mouseLocation.x // TODO: Implement proper idle time detection
                if idleTime > Double(self.settings.pauseAfterMinutes * 60) {
                    self.pauseTimers()
                    return
                }
            }
            
            if self.settings.resetOnIdle {
                let idleTime = NSEvent.mouseLocation.x // TODO: Implement proper idle time detection
                if idleTime > Double(self.settings.resetAfterMinutes * 60) {
                    self.resetTimers()
                    return
                }
            }
            
            if Date() >= self.nextBreakTime {
                self.startBreak()
            }
        }
        
        if let workTimer = workTimer {
            RunLoop.main.add(workTimer, forMode: .common)
        }
    }
    
    private func startBreakTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isBreakActive = true
            
            // Check if it's time for a long break
            let isLongBreak = self.settings.longBreaksEnabled && 
                            self.completedBreaks >= 0 && 
                            (self.completedBreaks + 1) % self.settings.longBreakInterval == 0
            print("isLongBreak: \(isLongBreak), completedBreaks: \(self.completedBreaks), longBreakInterval: \(self.settings.longBreakInterval)")
            
            // Set duration based on break type
            self.timeRemaining = isLongBreak ? self.settings.longBreakDuration : self.settings.shortBreakDuration
            self.postponeOptions = !self.settings.hideSkipButton
            
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    // Increment completed breaks counter and handle break completion
                    if isLongBreak {
                        // Reset counter after a long break
                        self.resetCompletedBreaks()
                    } else {
                        // Only increment for short breaks
                        self.completedBreaks += 1
                    }
                    self.skipBreak()
                }
            }
            
            if let timer = self.timer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    private func startCountdownTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.startBreakTimer()
            }
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func updateProgress() {
        let totalTime = TimeInterval(settings.workModeDuration * 60)
        let remainingTime = nextBreakTime.timeIntervalSince(Date())
        progress = max(0, min(1, (totalTime - remainingTime) / totalTime))
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
            
            // Show countdown if enabled
            if self.settings.showCountdown {
                DispatchQueue.main.async {
                    self.timeRemaining = self.settings.countdownDuration
                    self.startCountdownTimer()
                }
                return
            }
            
            // Start break immediately if countdown disabled
            self.startBreakTimer()
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
            
            // Only reset completed breaks if postponing a long break when its over
            if self.isBreakActive && self.settings.longBreaksEnabled && 
               self.completedBreaks >= 0 && 
               self.completedBreaks % self.settings.longBreakInterval == 0 {
                self.resetCompletedBreaks()
            }
            
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
        postponeBreak(minutes: settings.workModeDuration)
    }
    
    private func startLongBreak() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timeRemaining = self.settings.longBreakDuration
            self.startBreakTimer()
        }
    }
    
    private func pauseTimers() {
        timer?.invalidate()
        timer = nil
        workTimer?.invalidate()
        workTimer = nil
    }
    
    private func resetCompletedBreaks() {
        DispatchQueue.main.async {
            self.completedBreaks = 0
        }
    }
    
    private func resetTimers() {
        pauseTimers()
        resetCompletedBreaks()
        nextBreakTime = Date().addingTimeInterval(TimeInterval(settings.workModeDuration * 60))
        startWorkTimer()
    }
    
    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        workTimer?.invalidate()
        workTimer = nil
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
    
    deinit {
        print("RestModeManager: Deinitializing")
        cleanup()
    }
} 
