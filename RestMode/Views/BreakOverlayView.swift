import SwiftUI

struct BreakOverlayContainerView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Base layer - solid color
            Color.black.opacity(0.10)
                .ignoresSafeArea()
            
            // Blur layer
            Rectangle()
                .fill(.ultraThickMaterial)
                .opacity(0.95)
                .ignoresSafeArea()
            
            // Content
            if manager.isBreakActive {
                BreakView()
                    .environmentObject(manager)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
} 