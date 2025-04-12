import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressSection()
            
            Divider()
                .padding(.horizontal, 12)
            
            ActionButtons()
            
            Divider()
                .padding(.horizontal, 12)
            
            QuitButton()
        }
        .frame(width: 260)
        .padding(.vertical, 12)
    }
}

private struct ProgressSection: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image("Cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("Rest Time")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                ProgressBar(progress: manager.progress)
                
                HStack {
                    Text(timeString(from: Int(manager.nextBreakTime.timeIntervalSince(Date()))))
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text("until next break")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
    }
}

private struct ActionButtons: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 2) {
            MenuButton(
                title: "Start Break Now",
                icon: "play.circle.fill",
                color: .blue,
                isDestructive: false
            ) {
                manager.startBreak()
            }
            
            MenuButton(
                title: "Postpone 5 Minutes",
                icon: "clock.arrow.circlepath",
                color: .primary,
                isDestructive: false
            ) {
                manager.postponeBreak(minutes: 5)
            }
            
            MenuButton(
                title: "Skip to Next Hour",
                icon: "forward.end.fill",
                color: .primary,
                isDestructive: true
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
            color: .primary,
            isDestructive: true
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
    let isDestructive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(isDestructive ? Color.red : .primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(Color.primary.opacity(0.0001)) // Helps with hover
    }
}


