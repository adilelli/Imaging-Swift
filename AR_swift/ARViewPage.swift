import SwiftUI
import ARKit
import UIKit

struct ARViewPage: UIViewRepresentable {
//    let imageUrls: [URL] // Array of image URLs
    @Binding var imagesLoaded: Bool
    let files: [String]
    let url = URL(string: "https://f3df-219-92-198-46.ngrok-free.app/uploads")

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator

        // Assign the created sceneView to the coordinator for future reference
        context.coordinator.sceneView = sceneView

        // Configure AR session with world tracking and image detection
        let configuration = ARWorldTrackingConfiguration()
        
        loadImagesFromURLs(files: files) { referenceImages in
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
        var parent: ARViewPage
        var files: [String] // Add the `files` array here
        weak var sceneView: ARSCNView?

        init(_ parent: ARViewPage, files: [String]) {
            self.parent = parent
            self.files = files
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let sceneView = sceneView else {
                print("SceneView is missing")
                return
            }

            for (index, anchor) in anchors.enumerated() {
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
    func loadImagesFromURLs(files: [String], completion: @escaping ([ARReferenceImage]) -> Void) {
        let imageUrls = files.map { URL(string: url!.appendingPathComponent($0).absoluteString)! }
        var referenceImages: [ARReferenceImage] = []
        let dispatchGroup = DispatchGroup()
        
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, imageUrl) in imageUrls.enumerated() {
                dispatchGroup.enter()
                
                let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    defer { dispatchGroup.leave() }
                    
                    if let error = error {
                        print("Failed to download image from URL: \(imageUrl). Error: \(error)")
                        return
                    }
                    
                    guard let data = data, let cgImage = UIImage(data: data)?.cgImage else {
                        print("Failed to create CGImage from downloaded data for URL: \(imageUrl)")
                        return
                    }
                    
                    let arImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.2) // Adjust physical width as needed
                    arImage.name = files[index] // Assign a unique name to each image
                    referenceImages.append(arImage)
                }
                
                task.resume()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(referenceImages)
            }
        }
    }


}
