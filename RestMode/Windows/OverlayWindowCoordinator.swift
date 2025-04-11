import SwiftUI
import AppKit

class OverlayWindowCoordinator: ObservableObject {
    private var overlayPanel: OverlayPanel?
    private var overlayHostingView: NSHostingView<AnyView>?
    
    func showOverlay(with view: some View) {
        DispatchQueue.main.async { [weak self] in
            self?.createAndShowPanel(with: view)
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async { [weak self] in
            self?.overlayPanel?.close()
            self?.overlayPanel = nil
            self?.overlayHostingView = nil
        }
    }
    
    private func createAndShowPanel(with view: some View) {
        // Create the panel if it doesn't exist
        if overlayPanel == nil {
            overlayPanel = OverlayPanel.create()
        }
        
        // Create hosting view for SwiftUI content
        let hostingView = NSHostingView(rootView: AnyView(view))
        overlayHostingView = hostingView
        
        // Set the hosting view as the panel's content
        overlayPanel?.contentView = hostingView
        
        // Show the panel
        overlayPanel?.orderFrontRegardless()
    }
} 