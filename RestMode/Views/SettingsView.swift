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
                

                // TODO: Add these back in later when we have more settings
                // Section("Personalize") {
                //     Label(Tabs.customization.title, systemImage: Tabs.customization.icon)
                //         .tag(Tabs.customization)
                //     Label(Tabs.automation.title, systemImage: Tabs.automation.icon)
                //         .tag(Tabs.automation)
                //     Label(Tabs.notifications.title, systemImage: Tabs.notifications.icon)
                //         .tag(Tabs.notifications)
                //     Label(Tabs.keyboardShortcuts.title, systemImage: Tabs.keyboardShortcuts.icon)
                //         .tag(Tabs.keyboardShortcuts)
                // }
                
                Section("ReduceTime") {
                    Label(Tabs.about.title, systemImage: Tabs.about.icon)
                        .tag(Tabs.about)
                }
            }
            .listStyle(.sidebar)
            .frame(width: 220)
            
            ZStack {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
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
            }
            .padding(20)
        }
        .background {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Settings Views

struct GeneralSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Launch at login")
                            Spacer()
                            Toggle("",isOn: $settings.launchAtLogin)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                       HStack {
                        Text("Automatically check for updates")
                        Spacer()
                        Toggle("", isOn: $settings.autoCheckUpdates)
                            .toggleStyle(.switch)
                       }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("Startup", systemImage: "power")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Automatically check for updates")
                            Spacer()
                            Toggle("", isOn: $settings.autoCheckUpdates)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Automatically download updates")
                            Spacer()
                            Toggle("", isOn: $settings.autoDownloadUpdates)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        Button(action: {
                            // Implement update check
                        }) {
                            Text("Check for updates")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("Updates", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }
}

struct WorkModeSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Picker("Duration", selection: $settings.workModeDuration) {
                                Text("20 minutes").tag(20)
                                Text("30 minutes").tag(30)
                                Text("45 minutes").tag(45)
                                Text("1 hour").tag(60)
                            }
                            .labelsHidden()
                            .frame(width: 120)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("General", systemImage: "clock")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Enable work schedule")
                            Spacer()
                            Toggle("", isOn: $settings.enableWorkSchedule)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        Text("When enabled, ReduceTime will only show breaks during the set schedule")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("Work schedule", systemImage: "calendar")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("When you are inactive, ReduceTime can automatically pause and/or reset the timers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        HStack {
                            Text("Pause after")
                            Spacer()
                            Toggle("", isOn: $settings.pauseOnIdle)
                                .toggleStyle(.switch)
                        }
                        
                        if settings.pauseOnIdle {
                            HStack {
                                Picker("Pause duration", selection: $settings.pauseAfterMinutes) {
                                    ForEach([1, 2, 5, 10], id: \.self) { minutes in
                                        Text("\(minutes) minute\(minutes == 1 ? "" : "s")").tag(minutes)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 120)
                                Text("of inactivity")
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Reset all timers after")
                            Spacer()
                            Toggle("", isOn: $settings.resetOnIdle)
                                .toggleStyle(.switch)
                        }
                        
                        if settings.resetOnIdle {
                            HStack {
                                Picker("Reset duration", selection: $settings.resetAfterMinutes) {
                                    ForEach([5, 10, 15, 30], id: \.self) { minutes in
                                        Text("\(minutes) minutes").tag(minutes)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 120)
                                Text("of inactivity")
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("Idle time handling", systemImage: "zzz")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }
}

struct RestModeSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Picker("Duration", selection: $settings.shortBreakDuration) {
                                Text("20 seconds").tag(20)
                                Text("30 seconds").tag(30)
                                Text("45 seconds").tag(45)
                                Text("1 minute").tag(60)
                            }
                            .labelsHidden()
                            .frame(width: 120)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("Short breaks", systemImage: "clock")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Enable long breaks")
                            Spacer()
                            Toggle("", isOn: $settings.longBreaksEnabled)
                                .toggleStyle(.switch)
                        }
                        
                        if settings.longBreaksEnabled {
                            Divider()
                            
                            HStack {
                                Text("Duration")
                                Spacer()
                                Picker("Duration", selection: $settings.longBreakDuration) {
                                    Text("3 minutes").tag(180)
                                    Text("5 minutes").tag(300)
                                    Text("10 minutes").tag(600)
                                }
                                .labelsHidden()
                                .frame(width: 120)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Repeat after every")
                                Spacer()
                                Picker("Repeat after", selection: $settings.longBreakInterval) {
                                    ForEach([3, 4, 5, 6], id: \.self) { count in
                                        Text("\(count) short breaks").tag(count)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 120)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("Long breaks", systemImage: "clock.badge.checkmark")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Wait until I finish typing before showing a break")
                            Spacer()
                            Toggle("", isOn: $settings.waitForTyping)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Hide the Skip button everywhere")
                            Spacer()
                            Toggle("", isOn: $settings.hideSkipButton)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Prevent skipping a break for a few seconds after it starts")
                            Spacer()
                            Toggle("", isOn: $settings.preventSkipping)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Allow ending the break early if significant time has passed")
                            Spacer()
                            Toggle("", isOn: $settings.allowEarlyEnd)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Automatically lock the screen when a break starts")
                            Spacer()
                            Toggle("", isOn: $settings.autoLockScreen)
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Show a small countdown before a break starts")
                            Spacer()
                            Toggle("", isOn: $settings.showCountdown)
                                .toggleStyle(.switch)
                        }
                        
                        if settings.showCountdown {
                            HStack {
                                Picker("Countdown duration", selection: $settings.countdownDuration) {
                                    ForEach([3, 5, 10], id: \.self) { seconds in
                                        Text("\(seconds) seconds").tag(seconds)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 120)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                } label: {
                    Label("Behavior", systemImage: "gearshape")
                        .font(.headline).padding(.horizontal,-6).padding(.vertical,5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
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

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
} 
