/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view presents a 360° destination image in an immersive space.
*/

import SwiftUI
import RealityKit
import Combine

/// A view that displays a 360 degree scene in which to watch video.
struct DestinationView: View {
    
    @State private var video: Video
    @State private var destinationChanged = false
    
    @Environment(PlayerModel.self) private var model
    
    init(_ video: Video) {
        _video = State(initialValue: video)
    }
    
    var body: some View {
        RealityView { content in
            let rootEntity = Entity()
            Task {
                await rootEntity.addSkybox(for: video)
            }
            content.add(rootEntity)
        } update: { content in
            guard destinationChanged else { return }
            guard let entity = content.entities.first else { fatalError() }
            Task {
                await entity.updateTexture(for: video)
            }
            Task { @MainActor in
                destinationChanged = false
            }
        }
        // Handle the case where the app is already playing video in a destination and:
        // 1. The user opens the Up Next tab and navigates to a new item, or
        // 2. The user presses the "Play Next" button in the player UI.
        .onChange(of: model.currentItem) { oldValue, newValue in
            if let newValue, video != newValue {
                video = newValue
                destinationChanged = true
            }
        }
        .transition(.opacity)
    }
}

extension Entity {
    func addSkybox(for video: Video) async {
        guard let imageUrl = URL(string: video.sceneImageUrl) else { fatalError("Invalid scene image url") };

        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            let localUrl = try saveImageToLocalFile(data: data , name: video.id + "_scene")
            let texture = try await TextureResource(contentsOf: localUrl)
            var material = UnlitMaterial()
            material.color = .init(texture: .init(texture))
            self.components.set(ModelComponent(
                mesh: .generateSphere(radius: 1E3),
                materials: [material]
            ))
            self.scale *= .init(x: -1, y: 1, z: 1)
            self.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
            
            // Rotate the sphere to show the best initial view of the space.
            updateRotation(for: video)
        } catch {
            print("Error loading texture \(error)")
        }
    }
    
    func updateTexture(for video: Video) async {
        guard let imageUrl = URL(string: video.sceneImageUrl) else { fatalError("Invalid scene image url") };
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            let localUrl = try saveImageToLocalFile(data: data, name: video.id + "_scene")
            let texture = try await TextureResource(contentsOf: localUrl)
            
            guard var modelComponent = self.components[ModelComponent.self] else {
                fatalError("Should this be fatal? Probably.")
            }
            
            var material = UnlitMaterial()
            material.color = .init(texture: .init(texture))
            modelComponent.materials = [material]
            self.components.set(modelComponent)
            
            // Rotate the sphere to show the best initial view of the space.
            updateRotation(for: video)
 
        } catch {
            print("Error loading texture \(error)")
        }
        
    }
    
    func updateRotation(for video: Video) {
        // Rotate the immersive space around the Y-axis set the user's
        // initial view of the immersive scene.
        let angle = Angle.degrees(video.sceneRotationDegrees)
        let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
        self.transform.rotation = rotation
    }
    
    func saveImageToLocalFile(data: Data, name: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(name + ".png")
        try data.write(to: fileURL)
        return fileURL
    }
}
