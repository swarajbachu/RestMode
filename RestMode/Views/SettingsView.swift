import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general
        case workMode
        case restMode
        case wellnessReminders
        case customization
        case automation
        case notifications
        case keyboardShortcuts
        case about
        
        var title: String {
            switch self {
            case .general: return "General"
            case .workMode: return "Work Mode"
            case .restMode: return "Rest Mode"
            case .wellnessReminders: return "Wellness Reminders"
            case .customization: return "Customization"
            case .automation: return "Automation"
            case .notifications: return "Notifications"
            case .keyboardShortcuts: return "Keyboard Shortcuts"
            case .about: return "About"
            }
        }
        
        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .workMode: return "bolt"
            case .restMode: return "cloud"
            case .wellnessReminders: return "heart"
            case .customization: return "paintbrush"
            case .automation: return "repeat"
            case .notifications: return "bell"
            case .keyboardShortcuts: return "command"
            case .about: return "info.circle"
            }
        }
    }
    
    @State private var selectedTab: Tabs = .general
    @EnvironmentObject private var settings: SettingsManager
    
    var body: some View {
        HSplitView {
            List(selection: $selectedTab) {
                Section("Settings") {
                    Label(Tabs.general.title, systemImage: Tabs.general.icon)
                        .tag(Tabs.general)
                }
                
                Section("Productivity & Care") {
                    Label(Tabs.workMode.title, systemImage: Tabs.workMode.icon)
                        .tag(Tabs.workMode)
                    Label(Tabs.restMode.title, systemImage: Tabs.restMode.icon)
                        .tag(Tabs.restMode)
                    Label(Tabs.wellnessReminders.title, systemImage: Tabs.wellnessReminders.icon)
                        .tag(Tabs.wellnessReminders)
                }
                
                Section("Personalize") {
                    Label(Tabs.customization.title, systemImage: Tabs.customization.icon)
                        .tag(Tabs.customization)
                    Label(Tabs.automation.title, systemImage: Tabs.automation.icon)
                        .tag(Tabs.automation)
                    Label(Tabs.notifications.title, systemImage: Tabs.notifications.icon)
                        .tag(Tabs.notifications)
                    Label(Tabs.keyboardShortcuts.title, systemImage: Tabs.keyboardShortcuts.icon)
                        .tag(Tabs.keyboardShortcuts)
                }
                
                Section("ReduceTime") {
                    Label(Tabs.about.title, systemImage: Tabs.about.icon)
                        .tag(Tabs.about)
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 180, maxWidth: 220)
            
            Group {
                switch selectedTab {
                case .general:
                    GeneralSettingsView()
                case .workMode:
                    WorkModeSettingsView()
                case .restMode:
                    RestModeSettingsView()
                case .wellnessReminders:
                    WellnessRemindersView()
                case .customization:
                    CustomizationView()
                case .automation:
                    AutomationView()
                case .notifications:
                    NotificationsView()
                case .keyboardShortcuts:
                    KeyboardShortcutsView()
                case .about:
                    AboutView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
}

// MARK: - Settings Views

struct GeneralSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Toggle("Start timer automatically on launch", isOn: $settings.startTimerOnLaunch)
            }
            
            Section("Updates") {
                Toggle("Automatically check for updates", isOn: $settings.autoCheckUpdates)
                Toggle("Automatically download updates", isOn: $settings.autoDownloadUpdates)
                
                Button("Check for updates") {
                    // Implement update check
                }
                .buttonStyle(.bordered)
            }
        }
        .formStyle(.grouped)
    }
}

struct WorkModeSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        Form {
            Section("General") {
                HStack {
                    Text("Duration")
                    Spacer()
                    Picker("Duration", selection: $settings.workModeDuration) {
                        Text("20 minutes").tag(20)
                        Text("30 minutes").tag(30)
                        Text("45 minutes").tag(45)
                        Text("1 hour").tag(60)
                    }
                }
            }
            
            Section("Work schedule") {
                Toggle("Enable work schedule", isOn: $settings.enableWorkSchedule)
                Text("When enabled, ReduceTime will only show breaks during the set schedule")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("Idle time handling") {
                Text("When you are inactive, ReduceTime can automatically pause and/or reset the timers")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Toggle("Pause after", isOn: $settings.pauseOnIdle)
                if settings.pauseOnIdle {
                    HStack {
                        Spacer()
                        Picker("Pause duration", selection: $settings.pauseAfterMinutes) {
                            ForEach([1, 2, 5, 10], id: \.self) { minutes in
                                Text("\(minutes) minute\(minutes == 1 ? "" : "s")").tag(minutes)
                            }
                        }
                        Text("of inactivity")
                    }
                }
                
                Toggle("Reset all timers after", isOn: $settings.resetOnIdle)
                if settings.resetOnIdle {
                    HStack {
                        Spacer()
                        Picker("Reset duration", selection: $settings.resetAfterMinutes) {
                            ForEach([5, 10, 15, 30], id: \.self) { minutes in
                                Text("\(minutes) minutes").tag(minutes)
                            }
                        }
                        Text("of inactivity")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct RestModeSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        Form {
            Section("Short breaks") {
                HStack {
                    Text("Duration")
                    Spacer()
                    Picker("Duration", selection: $settings.shortBreakDuration) {
                        Text("20 seconds").tag(20)
                        Text("30 seconds").tag(30)
                        Text("45 seconds").tag(45)
                        Text("1 minute").tag(60)
                    }
                }
            }
            
            Section("Long breaks") {
                Toggle("Enabled", isOn: $settings.longBreaksEnabled)
                
                if settings.longBreaksEnabled {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Picker("Duration", selection: $settings.longBreakDuration) {
                            Text("3 minutes").tag(180)
                            Text("5 minutes").tag(300)
                            Text("10 minutes").tag(600)
                        }
                    }
                    
                    HStack {
                        Text("Repeat after every")
                        Spacer()
                        Picker("Repeat after", selection: $settings.longBreakInterval) {
                            ForEach([3, 4, 5, 6], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        Text("short breaks")
                    }
                }
            }
            
            Section("Misc") {
                Toggle("Wait until I finish typing before showing a break", isOn: $settings.waitForTyping)
                Toggle("Hide the Skip button everywhere", isOn: $settings.hideSkipButton)
                Toggle("Prevent skipping a break for a few seconds after it starts", isOn: $settings.preventSkipping)
                Toggle("Allow ending the break early if significant time has passed", isOn: $settings.allowEarlyEnd)
                Toggle("Automatically lock the screen when a break starts", isOn: $settings.autoLockScreen)
                
                HStack {
                    Toggle("Show a small countdown before a break starts", isOn: $settings.showCountdown)
                    if settings.showCountdown {
                        Picker("Countdown duration", selection: $settings.countdownDuration) {
                            ForEach([3, 5, 10], id: \.self) { seconds in
                                Text("\(seconds) seconds before").tag(seconds)
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// Placeholder views for other tabs
struct WellnessRemindersView: View {
    var body: some View {
        Text("Wellness Reminders Settings")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CustomizationView: View {
    var body: some View {
        Text("Customization Settings")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AutomationView: View {
    var body: some View {
        Text("Automation Settings")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotificationsView: View {
    var body: some View {
        Text("Notifications Settings")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct KeyboardShortcutsView: View {
    var body: some View {
        Text("Keyboard Shortcuts Settings")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AboutView: View {
    var body: some View {
        VStack() {
            Image("Cloud")
                .resizable()
                .frame(width: 128, height: 128)
            
            Text("ReduceTime")
                .font(.title)
            Text("Version 0.1")
                .foregroundStyle(.secondary)
        }
    }
} 
