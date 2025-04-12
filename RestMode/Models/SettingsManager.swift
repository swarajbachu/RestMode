import SwiftUI

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard
    
    // MARK: - General Settings
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: "launchAtLogin")
            objectWillChange.send()
            LaunchAtLoginManager.shared.setLaunchAtLogin(launchAtLogin)
        }
    }
    
    @Published var startTimerOnLaunch: Bool {
        didSet {
            defaults.set(startTimerOnLaunch, forKey: "startTimerOnLaunch")
            objectWillChange.send()
        }
    }
    
    @Published var autoCheckUpdates: Bool {
        didSet {
            defaults.set(autoCheckUpdates, forKey: "autoCheckUpdates")
            objectWillChange.send()
        }
    }
    
    @Published var autoDownloadUpdates: Bool {
        didSet {
            defaults.set(autoDownloadUpdates, forKey: "autoDownloadUpdates")
            objectWillChange.send()
        }
    }
    
    // MARK: - Work Mode Settings
    @Published var workModeDuration: Int {
        didSet {
            defaults.set(workModeDuration, forKey: "workModeDuration")
            objectWillChange.send()
        }
    }
    
    @Published var enableWorkSchedule: Bool {
        didSet {
            defaults.set(enableWorkSchedule, forKey: "enableWorkSchedule")
            objectWillChange.send()
        }
    }
    
    @Published var pauseOnIdle: Bool {
        didSet {
            defaults.set(pauseOnIdle, forKey: "pauseOnIdle")
            objectWillChange.send()
        }
    }
    
    @Published var pauseAfterMinutes: Int {
        didSet {
            defaults.set(pauseAfterMinutes, forKey: "pauseAfterMinutes")
            objectWillChange.send()
        }
    }
    
    @Published var resetOnIdle: Bool {
        didSet {
            defaults.set(resetOnIdle, forKey: "resetOnIdle")
            objectWillChange.send()
        }
    }
    
    @Published var resetAfterMinutes: Int {
        didSet {
            defaults.set(resetAfterMinutes, forKey: "resetAfterMinutes")
            objectWillChange.send()
        }
    }
    
    // MARK: - Rest Mode Settings
    @Published var shortBreakDuration: Int {
        didSet {
            defaults.set(shortBreakDuration, forKey: "shortBreakDuration")
            objectWillChange.send()
        }
    }
    
    @Published var longBreaksEnabled: Bool {
        didSet {
            defaults.set(longBreaksEnabled, forKey: "longBreaksEnabled")
            objectWillChange.send()
        }
    }
    
    @Published var longBreakDuration: Int {
        didSet {
            defaults.set(longBreakDuration, forKey: "longBreakDuration")
            objectWillChange.send()
        }
    }
    
    @Published var longBreakInterval: Int {
        didSet {
            defaults.set(longBreakInterval, forKey: "longBreakInterval")
            objectWillChange.send()
        }
    }
    
    @Published var waitForTyping: Bool {
        didSet {
            defaults.set(waitForTyping, forKey: "waitForTyping")
            objectWillChange.send()
        }
    }
    
    @Published var hideSkipButton: Bool {
        didSet {
            defaults.set(hideSkipButton, forKey: "hideSkipButton")
            objectWillChange.send()
        }
    }
    
    @Published var preventSkipping: Bool {
        didSet {
            defaults.set(preventSkipping, forKey: "preventSkipping")
            objectWillChange.send()
        }
    }
    
    @Published var allowEarlyEnd: Bool {
        didSet {
            defaults.set(allowEarlyEnd, forKey: "allowEarlyEnd")
            objectWillChange.send()
        }
    }
    
    @Published var autoLockScreen: Bool {
        didSet {
            defaults.set(autoLockScreen, forKey: "autoLockScreen")
            objectWillChange.send()
        }
    }
    
    @Published var showCountdown: Bool {
        didSet {
            defaults.set(showCountdown, forKey: "showCountdown")
            objectWillChange.send()
        }
    }
    
    @Published var countdownDuration: Int {
        didSet {
            defaults.set(countdownDuration, forKey: "countdownDuration")
            objectWillChange.send()
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Set default values first
        self.workModeDuration = 60
        self.pauseAfterMinutes = 1
        self.resetAfterMinutes = 5
        self.shortBreakDuration = 30
        self.longBreakDuration = 180
        self.longBreakInterval = 3
        self.countdownDuration = 5
        self.startTimerOnLaunch = true
        self.autoCheckUpdates = true
        self.autoDownloadUpdates = false
        self.longBreaksEnabled = true
        self.preventSkipping = true
        self.showCountdown = true
        
        // Initialize launch at login from actual system state
        self.launchAtLogin = LaunchAtLoginManager.shared.isEnabled()
        
        // Then load from UserDefaults, overriding defaults if values exist
        if defaults.object(forKey: "workModeDuration") != nil {
            self.workModeDuration = defaults.integer(forKey: "workModeDuration")
        }
        if defaults.object(forKey: "pauseAfterMinutes") != nil {
            self.pauseAfterMinutes = defaults.integer(forKey: "pauseAfterMinutes")
        }
        if defaults.object(forKey: "resetAfterMinutes") != nil {
            self.resetAfterMinutes = defaults.integer(forKey: "resetAfterMinutes")
        }
        if defaults.object(forKey: "shortBreakDuration") != nil {
            self.shortBreakDuration = defaults.integer(forKey: "shortBreakDuration")
        }
        if defaults.object(forKey: "longBreakDuration") != nil {
            self.longBreakDuration = defaults.integer(forKey: "longBreakDuration")
        }
        if defaults.object(forKey: "longBreakInterval") != nil {
            self.longBreakInterval = defaults.integer(forKey: "longBreakInterval")
        }
        if defaults.object(forKey: "countdownDuration") != nil {
            self.countdownDuration = defaults.integer(forKey: "countdownDuration")
        }
        
        // Load boolean settings
        self.startTimerOnLaunch = defaults.bool(forKey: "startTimerOnLaunch")
        self.autoCheckUpdates = defaults.bool(forKey: "autoCheckUpdates")
        self.autoDownloadUpdates = defaults.bool(forKey: "autoDownloadUpdates")
        self.enableWorkSchedule = defaults.bool(forKey: "enableWorkSchedule")
        self.pauseOnIdle = defaults.bool(forKey: "pauseOnIdle")
        self.resetOnIdle = defaults.bool(forKey: "resetOnIdle")
        self.longBreaksEnabled = defaults.bool(forKey: "longBreaksEnabled")
        self.waitForTyping = defaults.bool(forKey: "waitForTyping")
        self.hideSkipButton = defaults.bool(forKey: "hideSkipButton")
        self.preventSkipping = defaults.bool(forKey: "preventSkipping")
        self.allowEarlyEnd = defaults.bool(forKey: "allowEarlyEnd")
        self.autoLockScreen = defaults.bool(forKey: "autoLockScreen")
        self.showCountdown = defaults.bool(forKey: "showCountdown")
    }
    
    // MARK: - Public Methods
    func resetToDefaults() {
        launchAtLogin = false
        startTimerOnLaunch = true
        autoCheckUpdates = true
        autoDownloadUpdates = false
        
        workModeDuration = 60
        enableWorkSchedule = false
        pauseOnIdle = true
        pauseAfterMinutes = 1
        resetOnIdle = true
        resetAfterMinutes = 5
        
        shortBreakDuration = 30
        longBreaksEnabled = true
        longBreakDuration = 180
        longBreakInterval = 3
        waitForTyping = false
        hideSkipButton = false
        preventSkipping = true
        allowEarlyEnd = false
        autoLockScreen = false
        showCountdown = true
        countdownDuration = 5
    }
} 