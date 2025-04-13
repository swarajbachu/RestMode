import SwiftUI

// Separate view for timer display to isolate updates
struct TimerDisplay: View {
    @ObservedObject var timerState: TimerState
    
    var body: some View {
        Text(formatTimeRemaining(Int(timerState.nextBreakTime.timeIntervalSince(Date()))))
            .font(.system(.body, design: .monospaced).bold())
            .fixedSize()
            .frame(minWidth: 40, alignment: .trailing)
            .foregroundStyle(.primary)
    }
    
    private func formatTimeRemaining(_ seconds: Int) -> String {
        if seconds <= 0 {
            return "0s"
        }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes):\(remainingSeconds < 10 ? "0" : "")\(remainingSeconds)"
    }
}

// Menu item component to reduce redundancy
struct MenuItem: View {
    let title: String
    let shortcut: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Text(shortcut)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 3)
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject var manager: RestModeManager
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MenuItem(title: "Start Break Now", shortcut: "⌘B") {
                manager.startBreak()
            }
            .keyboardShortcut("b", modifiers: .command)
            
            MenuItem(title: "Skip to Next Hour", shortcut: "⇧⌘S") {
                manager.skipBreak()
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
            
            Menu {
                ForEach([1, 2, 3, 5, 10], id: \.self) { minutes in
                    Button(action: { manager.addWorkTime(minutes: minutes) }) {
                        Text("\(minutes) Minute\(minutes == 1 ? "" : "s")")
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Add Time")
                    Spacer()
                    Text("⌘T")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
            }
            
            Divider()
            
            MenuItem(title: "Settings...", shortcut: "⌘,") {
                SettingsWindowManager().showSettingsWindow()
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Divider()
            
            MenuItem(title: "Quit RestMode", shortcut: "⌘Q") {
                manager.cleanup()
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

