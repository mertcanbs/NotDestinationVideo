/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object that represents a video in the app's library.
*/

import Foundation
import UIKit

struct Video: Identifiable, Hashable, Codable {
    
    /// The unique identifier of the item.
    let id: String
    /// The URL of the video, which can be local or remote.
    let url: URL
    /// The title of the video.
    let title: String
    /// The description of the video.
    let description: String
    /// The URL of the video's portrait image.
    var portraitImageUrl: String
    /// The URL of the video's landscape image.
    var landscapeImageUrl: String
    /// The URL of the video's scene image.
    var sceneImageUrl: String
    /// The initial rotation degrees of the scene image.
    var sceneRotationDegrees: Double = 0
    /// The data for the landscape image to create a metadata item to display in the Info panel.
    var imageData: Data {
        UIImage(named: landscapeImageUrl)?.pngData() ?? Data()
    }
    /// Detailed information about the video like its stars and content rating.
    let info: Info
    /// A url that resolves to specific local or remote media.
    var resolvedURL: URL {
        if url.scheme == nil {
            return URL(fileURLWithPath: "\(Bundle.main.bundlePath)/\(url.path)")
        }
        return url
    }
    
    /// A Boolean value that indicates whether the video is hosted in a remote location.
    var hasRemoteMedia: Bool {
        url.scheme != nil
    }
    
    /// An object that provides detailed information for a video.
    struct Info: Hashable, Codable {
        var releaseYear: String
        var contentRating: String
        var duration: String
        var genres: [String]
        var stars: [String]
        var directors: [String]
        var writers: [String]
        
        var releaseDate: Date {
            var components = DateComponents()
            components.year = Int(releaseYear)
            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(from: components)!
        }
    }
}
