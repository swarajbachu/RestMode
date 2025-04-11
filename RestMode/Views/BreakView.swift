import SwiftUI

struct BreakView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    Color(colorScheme == .dark ? .black : .white)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 40) {
                TimerSection()
                
                if manager.postponeOptions {
                    PostponeOptions()
                }
            }
            .padding(40)
        }
    }
}

private struct TimerSection: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 25) {
            TimerCircle()
            
            VStack(spacing: 12) {
                Text("Time to Rest Your Eyes")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Look at something 20 feet away\nto reduce eye strain")
                    .font(.body)
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
            // Timer circle
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: CGFloat(manager.timeRemaining) / (20 * 60))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 8) {
                Text(timeString(from: manager.timeRemaining))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                
                Text("remaining")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct PostponeOptions: View {
    @EnvironmentObject var manager: RestModeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Not a good time?")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                PostponeButton(
                    title: "5 min",
                    icon: "clock",
                    color: .orange
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
                    color: .red
                ) {
                    manager.skipBreak()
                }
            }
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 40)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

private struct PostponeButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.headline)
            }
            .frame(width: 100)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
} 