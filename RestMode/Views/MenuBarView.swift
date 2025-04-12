import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var manager: RestModeManager
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { manager.startBreak() }) {
                HStack {
                    Text("Start Break Now")
                    Spacer()
                    Text("⌘B")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Button(action: { manager.skipBreak() }) {
                HStack {
                    Text("Skip to Next Hour")
                    Spacer()
                    Text("⇧⌘S")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
            
            Menu {
                Button(action: { manager.addWorkTime(minutes: 1) }) {
                    Text("1 Minute")
                }
                Button(action: { manager.addWorkTime(minutes: 2) }) {
                    Text("2 Minutes")
                }
                Button(action: { manager.addWorkTime(minutes: 3) }) {
                    Text("3 Minutes")
                }
                Button(action: { manager.addWorkTime(minutes: 5) }) {
                    Text("5 Minutes")
                }
                Button(action: { manager.addWorkTime(minutes: 10) }) {
                    Text("10 Minutes")
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
            
            Button(action: { SettingsWindowManager().showSettingsWindow() }) {
                HStack {
                    Text("Settings...")
                    Spacer()
                    Text("⌘,")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Divider()
            
            Button(action: {
                manager.cleanup()
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Text("Quit RestMode")
                    Spacer()
                    Text("⌘Q")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
    
    // Helper function to format time
    private func formatTimeRemaining(_ seconds: Int) -> String {
        if seconds <= 0 {
            return "0s"
        }
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        return "\(minutes)m"
    }
}

