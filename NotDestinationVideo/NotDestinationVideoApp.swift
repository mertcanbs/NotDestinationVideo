//
//  NotDestinationVideoApp.swift
//  NotDestinationVideo
//
//  Created by Mert on 11/16/23.
//

import SwiftUI
import os

@main
struct NotDestinationVideoApp: App {
    
    /// An object that controls the video playback behavior.
    @State private var player = PlayerModel()
    /// An object that manages the library of video content.
    @State private var library = VideoLibrary()
    
    var body: some Scene {
        // The app's primary content window.
        WindowGroup {
            ContentView()
                .environment(player)
                .environment(library)
#if !os(visionOS)
            // Use a dark color scheme on supported platforms.
                .preferredColorScheme(.dark)
                .tint(.white)
#endif
        }
#if os(visionOS)
        // Defines an immersive space to present a destination in which to watch the video.
        ImmersiveSpace(for: Video.self) { $video in
            if let video {
                DestinationView(video)
                    .environment(player)
            }
        }
        // Set the immersion style to progressive, so the user can use the crown to dial in their experience.
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
#endif
    }
}

/// A global logger for the app.
let logger = Logger()
