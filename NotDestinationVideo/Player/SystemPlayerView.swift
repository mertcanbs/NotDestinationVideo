/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that provides a platform-specific playback user interface.
*/

import AVKit
import SwiftUI

// This view is a SwiftUI wrapper over `AVPlayerViewController`.
struct SystemPlayerView: UIViewControllerRepresentable {

    @Environment(PlayerModel.self) private var model
    @Environment(VideoLibrary.self) private var library
    
    let showContextualActions: Bool
    
    init(showContextualActions: Bool) {
        self.showContextualActions = showContextualActions
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        // Create a player view controller.
        let controller = model.makePlayerViewController()
        
        // Enable PiP on iOS and tvOS.
        controller.allowsPictureInPicturePlayback = true

        // Return the configured controller object.
        return controller
    }
    
    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        #if os(visionOS) || os(tvOS)
        Task { @MainActor in
            // Rebuild the list of related video if necessary.
            
            if let upNextAction, showContextualActions {
                controller.contextualActions = [upNextAction]
            } else {
                controller.contextualActions = []
            }
        }
        #endif
    }
    
    var upNextAction: UIAction? {
        // If there's no video loaded, return nil.
        guard let video = model.currentItem else { return nil }

        // Find the next video to play.
        guard let nextVideo = library.findVideoInUpNext(after: video) else { return nil }
        
        return UIAction(title: "Play Next", image: UIImage(systemName: "play.fill")) { _ in
            // Load the video for full-window presentation.
            model.loadVideo(nextVideo, presentation: .fullWindow)
        }
    }
}
