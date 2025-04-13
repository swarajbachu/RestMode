import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var player: AVAudioPlayer?
    
    private init() {}
    
    func playSound(_ type: SystemSoundType) {
        var systemSoundID: SystemSoundID = 0
        
        switch type {
        case .complete:
            systemSoundID = 1004 // Glass sound
        case .dismiss:
            systemSoundID = 1255 // Swoosh sound
        }
        
        AudioServicesPlaySystemSound(systemSoundID)
    }
}

enum SystemSoundType {
    case complete
    case dismiss
} 