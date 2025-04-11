import SwiftUI

struct BreakOverlayContainerView: View {
    @EnvironmentObject var manager: RestModeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var isPresented = false // Use a single state for presence
    
    var body: some View {
        ZStack {
            // Clean, minimal material background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .opacity(isPresented ? 1 : 0) // Animate the background opacity
            
            // Content
            if manager.isBreakActive {
                BreakView(isPresented: isPresented)
                    .environmentObject(manager)
                    // Keep content animation tied to overall presence
                    .scaleEffect(isPresented ? 1 : 0.95)
                    .opacity(isPresented ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        // Animate the whole container based on manager.isBreakActive change
        .onChange(of: manager.isBreakActive) { _, isActive in
            withAnimation(.easeOut(duration: 0.35)) {
                isPresented = isActive
            }
        }
        // Ensure initial state is correct
        .onAppear {
            // Set initial state without animation
            isPresented = manager.isBreakActive
            // Trigger animation if appearing initially active
            if isPresented {
                DispatchQueue.main.async {
                     withAnimation(.easeOut(duration: 0.35)) {
                        // Re-assign to trigger animation if needed on first appear
                        self.isPresented = true 
                    }
                }
            }
        }
    }
} 