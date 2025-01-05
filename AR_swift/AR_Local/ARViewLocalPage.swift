//
//  ARViewLocalPage.swift
//  AR_swift
//
//  Created by Adil Elli on 05/01/2025.
//

import SwiftUI
import ARKit
import UIKit

struct ARViewLocalPage: UIViewRepresentable {
    @Binding var imagesLoaded: Bool
    let files: [String]
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator

        // Assign the created sceneView to the coordinator for future reference
        context.coordinator.sceneView = sceneView

        // Configure AR session with world tracking and image detection
        let configuration = ARWorldTrackingConfiguration()
        
        loadImagesFromFiles(files: files) { referenceImages in
            guard !referenceImages.isEmpty else {
                print("No images could be loaded.")
                return
            }
            configuration.detectionImages = Set(referenceImages)
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            imagesLoaded = true
        }

        return sceneView
    }
    

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // No dynamic updates needed in this case
    }

    func makeCoordinator() -> ViewARHi {
        ViewARHi(self, files: files)
    }

    class ViewARHi: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARViewLocalPage
        var files: [String] // Add the `files` array here
        weak var sceneView: ARSCNView?

        init(_ parent: ARViewLocalPage, files: [String]) {
            self.parent = parent
            self.files = files
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let sceneView = sceneView else {
                print("SceneView is missing")
                return
            }

            for (_, anchor) in anchors.enumerated() {
                guard let imageAnchor = anchor as? ARImageAnchor else { continue }

                // Introduce a delay to allow the anchor node to become available in the scene
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self, let anchorNode = sceneView.node(for: imageAnchor) else {
                        print("Failed to add cube: Anchor node is missing.")
                        return
                    }
                    
                    let imageName = imageAnchor.referenceImage.name
                    let textGeometry = SCNText(string: imageName, extrusionDepth: 1.0)
                        textGeometry.font = UIFont.systemFont(ofSize: 5)
                        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
                        textGeometry.firstMaterial?.isDoubleSided = true
                        
                    let textNode = SCNNode(geometry: textGeometry)
                    
                    // Adjust text scale
                    let scale: Float = 0.005 // Scale down the size of the text
                    textNode.scale = SCNVector3(x: scale, y: scale, z: scale)
                    let rotationAngle: Float = .pi / 2  // 45 degrees in radians
//                    let fortyFiveAngle: Float = .pi / 4
//                    let oneEighty: Float = .pi
                    
//                    textNode.rotation = SCNVector4(-1, 0, 0, rotationAngle)  // Rotate along X-axis
                    textNode.eulerAngles = SCNVector3(0, rotationAngle, rotationAngle)
                    textNode.position = SCNVector3(x: -0.0, y: -0.1, z: 0.0)

                    // Attach the cube node to the image anchor node
                    anchorNode.addChildNode(textNode)
                    
                    print("Cube added at position: \(textNode.position)")
//                    print(imageName)
                }
            }

        }

    }

    // Helper function to download images from URLs
    private func loadImagesFromFiles(files: [String], completion: @escaping ([ARReferenceImage]) -> Void) {
        var referenceImages: [ARReferenceImage] = []

        // Iterate over files and create ARReferenceImage objects
        for file in files {
            guard let documentsDirectory = documentsDirectory else { continue }
            let fileURL = documentsDirectory.appendingPathComponent(file)

            guard let image = UIImage(contentsOfFile: fileURL.path),
                  let cgImage = image.cgImage else {
                print("Could not load image: \(file)")
                continue
            }

            // Create ARReferenceImage with a physical size (1 meter as an example, adjust as needed)
            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.1) // 0.1 meters (10 cm)
            referenceImage.name = file
            referenceImages.append(referenceImage)
        }

        // Pass back the reference images
        completion(referenceImages)
    }


}
