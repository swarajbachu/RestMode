import Foundation

func timeString(from seconds: Int) -> String {
    let minutes = max(0, seconds) / 60
    let remainingSeconds = max(0, seconds) % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
} 