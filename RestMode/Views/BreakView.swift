import SwiftUI

struct BreakView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    let isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            // Main content
            VStack(spacing: 40) {
                // Current time
                Text(Date.now, style: .time)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .offset(y: isPresented ? 0 : -20)
                    .opacity(isPresented ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: isPresented)
                
                TimerSection()
                    .offset(y: isPresented ? 0 : 20)
                    .opacity(isPresented ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.1), value: isPresented)
            }
            
            Spacer()
            
            if manager.postponeOptions {
                PostponeOptions()
                    .offset(y: isPresented ? 0 : 20)
                    .opacity(isPresented ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.15), value: isPresented)
                    .padding(.bottom, 16)
            }
        }
        .padding(32)
    }
}

private struct TimerSection: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text(manager.timerState.isLongBreak ? "Time for a Long Break" : "Time for a Break")
                    .font(.system(size: 24, weight: .medium))
                
                Text("Look at something 20 feet away")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            TimerBar(manager: manager)
        }
    }
}

private struct TimerBar: View {
    @EnvironmentObject var manager: RestModeManager
    @ObservedObject private var timerState: TimerState
    
    init(manager: RestModeManager) {
        self._timerState = ObservedObject(wrappedValue: manager.timerState)
    }
    
    var body: some View {
        let totalDuration = timerState.isLongBreak ? 
            manager.settings.longBreakDuration : 
            manager.settings.shortBreakDuration
        
        VStack(spacing: 20) {
            // Timer text
            Text(timeString(from: timerState.timeRemaining))
                .font(.system(size: 52, weight: .medium, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: timerState.timeRemaining)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 4)
                    
                    // Progress bar
                    Capsule()
                        .fill(Color.primary.opacity(0.3))
                        .frame(
                            width: geometry.size.width * CGFloat(timerState.timeRemaining) / CGFloat(totalDuration),
                            height: 4
                        )
                }
            }
            .frame(width: 200, height: 4)
            .animation(.smooth, value: timerState.timeRemaining)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

private struct PostponeOptions: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Postpone buttons
            HStack(spacing: 20) {
                PostponeButton(
                    title: "5 min",
                    action: { manager.postponeBreak(minutes: 5) }
                )
                
                PostponeButton(
                    title: "10 min",
                    action: { manager.postponeBreak(minutes: 10) }
                )
            }
            
            // Skip button
            Button(action: { manager.skipBreak() }) {
                HStack(spacing: 6) {
                    Image(systemName: "forward.end")
                        .font(.system(size: 12, weight: .medium))
                    Text("Skip")
                        .font(.system(size: 15, weight: .regular))
                }
                .frame(width: 90, height: 36)
                .background(Color.primary.opacity(0.05))
                .clipShape(Capsule())
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct PostponeButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 90, height: 36)
                .background(Color.primary.opacity(0.05))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

