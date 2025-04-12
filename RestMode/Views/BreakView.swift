import SwiftUI

struct BreakView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    // Receive animation state
    let isPresented: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            TimerSection()
                // Animate timer section
                .offset(y: isPresented ? 0 : 20)
                .opacity(isPresented ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.1), value: isPresented)
            
            if manager.postponeOptions {
                PostponeOptions()
                    // Animate postpone options (slightly delayed)
                    .offset(y: isPresented ? 0 : 20)
                    .opacity(isPresented ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.15), value: isPresented)
            }
        }
        .padding(40)
    }
}

private struct TimerSection: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 32) {
            TimerCircle()
            
            VStack(spacing: 10) {
                Text("Time for an Eye Break")
                    .font(.system(size: 24, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text("Look at something 20 feet away")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

private struct TimerCircle: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.secondary.opacity(0.1), lineWidth: 8)
                .frame(width: 180, height: 180)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(manager.timeRemaining) / 20.0)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
                .animation(.smooth, value: manager.timeRemaining)
            
            VStack(spacing: 4) {
                Text(timeString(from: manager.timeRemaining))
                    .font(.system(size: 44, weight: .medium, design: .rounded))
                    .monospacedDigit()
                
                Text("seconds")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct PostponeOptions: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Need more time?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                PostponeButton(
                    title: "5 min",
                    icon: "clock",
                    color: .blue
                ) {
                    manager.postponeBreak(minutes: 5)
                }
                
                PostponeButton(
                    title: "10 min",
                    icon: "clock.arrow.circlepath",
                    color: .blue
                ) {
                    manager.postponeBreak(minutes: 10)
                }
                
                PostponeButton(
                    title: "Skip",
                    icon: "forward.end.fill",
                    color: .secondary
                ) {
                    manager.skipBreak()
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.03), radius: 10, y: 4)
        )
    }
}

private struct PostponeButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

