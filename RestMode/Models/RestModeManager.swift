import SwiftUI
import UserNotifications
import Combine

// Separate timer state to prevent UI re-renders
final class TimerState: ObservableObject {
    @Published var timeRemaining: Int {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var nextBreakTime = Date()
    @Published var progress: Double = 0.0
    @Published var isLongBreak = false
    
    init(initialTime: Int = 20) {
        self.timeRemaining = initialTime
    }
    
    func updateNextBreak(to date: Date) {
        self.nextBreakTime = date
        objectWillChange.send()
    }
    
    func updateTimeRemaining(_ seconds: Int) {
        DispatchQueue.main.async {
            self.timeRemaining = seconds
            self.objectWillChange.send()
        }
    }
    
    func decrementTimeRemaining() {
        DispatchQueue.main.async {
            self.timeRemaining = max(0, self.timeRemaining - 1)
            self.objectWillChange.send()
        }
    }
    
    func updateProgress(totalTime: TimeInterval) {
        let remainingTime = self.nextBreakTime.timeIntervalSince(Date())
        self.progress = max(0, min(1, (totalTime - remainingTime) / totalTime))
        objectWillChange.send()
    }
    
    func setLongBreak(_ isLong: Bool) {
        self.isLongBreak = isLong
        objectWillChange.send()
    }
}

class RestModeManager: ObservableObject {

    // MARK: - Published Properties
    @Published var isBreakActive = false
    @Published var postponeOptions = true
    @Published private(set) var completedBreaks = 0
    
    // MARK: - Timer State
    @Published var timerState: TimerState
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var workTimer: Timer?
    private var isCleaningUp = false
    private let serialQueue = DispatchQueue(label: "com.restmode.serial", qos: .userInteractive)
    let settings: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(settings: SettingsManager = .shared) {
        print("RestModeManager: Initializing")
        self.settings = settings
        self.timerState = TimerState(initialTime: settings.shortBreakDuration)
        
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
                if self.timerState.timeRemaining <= self.settings.shortBreakDuration {
                    self.timerState.updateTimeRemaining(newDuration)
                }
            }
            .store(in: &cancellables)
        
        // Observe long break duration changes
        settings.$longBreakDuration
            .sink { [weak self] newDuration in
                guard let self = self, self.isBreakActive else { return }
                // Only update if we're in a long break
                if self.timerState.timeRemaining > self.settings.shortBreakDuration {
                    self.timerState.updateTimeRemaining(newDuration)
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
        let nextBreak = Date().addingTimeInterval(TimeInterval(duration * 60))
        timerState.updateNextBreak(to: nextBreak)
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
            
            if Date() >= self.timerState.nextBreakTime {
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
                            self.completedBreaks > 0 && 
                            (self.completedBreaks % self.settings.longBreakInterval == 0)
            
            // Set duration based on break type
            let duration = isLongBreak ? self.settings.longBreakDuration : self.settings.shortBreakDuration
            self.timerState.setLongBreak(isLongBreak)
            self.timerState.updateTimeRemaining(duration)
            self.postponeOptions = !self.settings.hideSkipButton
            
            print("Starting \(isLongBreak ? "long" : "short") break. Duration: \(duration)s, Completed breaks: \(self.completedBreaks)")
            
            self.timer?.invalidate()
            // Create and schedule the timer on the main thread
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.timerState.timeRemaining > 0 {
                    self.timerState.decrementTimeRemaining()
                } else {
                    if isLongBreak {
                        self.resetCompletedBreaks()
                    } else {
                        self.completedBreaks += 1
                    }
                    SoundManager.shared.playSound(.complete)
                    self.skipBreak()
                }
            }
        }
    }
    
    private func startCountdownTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timerState.timeRemaining > 0 {
                self.timerState.decrementTimeRemaining()
            } else {
                self.startBreakTimer()
            }
        }
        
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func updateProgress() {
        let totalTime = TimeInterval(settings.workModeDuration * 60)
        timerState.updateProgress(totalTime: totalTime)
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
                    self.timerState.updateTimeRemaining(self.settings.countdownDuration)
                    self.startCountdownTimer()
                }
            } else {
                // Start break immediately if countdown disabled
                self.startBreakTimer()
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
            
            // Only reset completed breaks if postponing a long break when its over
            if self.isBreakActive && self.settings.longBreaksEnabled && 
               self.completedBreaks >= 0 && 
               self.completedBreaks % self.settings.longBreakInterval == 0 {
                self.resetCompletedBreaks()
            }
            
            // Update state
            DispatchQueue.main.async {
                if self.isBreakActive {
                    SoundManager.shared.playSound(.dismiss)
                }
                self.isBreakActive = false
                self.timerState.updateNextBreak(to: Date().addingTimeInterval(TimeInterval(minutes * 60)))
                self.startWorkTimer()
                self.scheduleNotification()
            }
        }
    }
    
    func skipBreak() {
        print("RestModeManager: Skipping break")
        SoundManager.shared.playSound(.dismiss)
        postponeBreak(minutes: settings.workModeDuration)
    }
    
    private func startLongBreak() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timerState.updateTimeRemaining(self.settings.longBreakDuration)
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
        timerState.updateNextBreak(to: Date().addingTimeInterval(TimeInterval(settings.workModeDuration * 60)))
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
        
        let timeInterval = timerState.nextBreakTime.timeIntervalSince(Date())
        // Only schedule if the time interval is positive
        guard timeInterval > 0 else {
            print("RestModeManager: Cannot schedule notification - time interval must be positive")
            return
        }
        
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
    
    func addWorkTime(minutes: Int) {
        print("RestModeManager: Adding \(minutes) minutes to work time")
        guard !isCleaningUp else {
            print("RestModeManager: Cannot add work time while cleaning up")
            return
        }
        
        serialQueue.async { [weak self] in
            guard let self = self, !self.isBreakActive else {
                print("RestModeManager: Cannot add work time during an active break")
                return
            }
            
            // Stop existing work timer
            self.workTimer?.invalidate()
            self.workTimer = nil
            
            // Update state
            DispatchQueue.main.async {
                self.timerState.updateNextBreak(to: self.timerState.nextBreakTime.addingTimeInterval(TimeInterval(minutes * 60)))
                self.updateProgress() // Update progress immediately
                self.startWorkTimer() // Restart timer with new end time
                self.scheduleNotification() // Reschedule notification
            }
        }
    }
    
    deinit {
        print("RestModeManager: Deinitializing")
        cleanup()
    }
} 
