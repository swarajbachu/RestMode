import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProgressSection()
            
            Divider()
            
            ActionButtons()
            
            Divider()
            
            QuitButton()
        }
        .frame(width: 240)
    }
}

private struct ProgressSection: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("Cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text("Rest Time")
                    .font(.headline)
                Spacer()
            }
            
            ProgressBar(progress: manager.progress)
            
            HStack {
                Text(timeString(from: Int(manager.nextBreakTime.timeIntervalSince(Date()))))
                    .font(.system(.body, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("until break")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 4)
            
            Capsule()
                .fill(Color.blue)
                .frame(width: 200 * progress, height: 4)
        }
    }
}

private struct ActionButtons: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 0) {
            MenuButton(
                title: "Start Break Now",
                icon: "play.circle.fill",
                color: .blue
            ) {
                manager.startBreak()
            }
            
            MenuButton(
                title: "Postpone 5 Minutes",
                icon: "clock.arrow.circlepath",
                color: .orange
            ) {
                manager.postponeBreak(minutes: 5)
            }
            
            MenuButton(
                title: "Skip to Next Hour",
                icon: "forward.circle.fill",
                color: .red
            ) {
                manager.skipBreak()
            }
        }
    }
}

private struct QuitButton: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        MenuButton(
            title: "Quit RestMode",
            icon: "power",
            color: .secondary
        ) {
            manager.cleanup()
            NSApplication.shared.terminate(nil)
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
} 