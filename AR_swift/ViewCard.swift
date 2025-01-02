import SwiftUI
import ARKit
import SceneKit
import UIKit

// Wrapper for ViewCard to use in SwiftUI
struct ViewCardSwiftUI: UIViewRepresentable {
    func makeUIView(context: Context) -> ViewCard {
        return ViewCard(frame: .zero) // Use the custom UIView
    }

    func updateUIView(_ uiView: ViewCard, context: Context) {
        // Handle updates if needed
    }
}


class ViewCard: UIView, ARSCNViewDelegate {
    private let sceneView = ARSCNView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSceneView()
        setupARSession()
        addTranslucentCard()
        addAxes()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSceneView()
        setupARSession()
        addTranslucentCard()
        addAxes()
    }

    private func setupSceneView() {
        sceneView.frame = bounds
        addSubview(sceneView)
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
    }

    private func setupARSession() {
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    private func addTranslucentCard() {
        // Create card geometry
        let plane = SCNPlane(width: 0.2, height: 0.1)
        plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.6) // Translucent white
        plane.firstMaterial?.isDoubleSided = true

        // Create a node for the card
        let cardNode = SCNNode(geometry: plane)
        cardNode.position = SCNVector3(0.1, 0.05, -0.5) // Place 50 cm in front of the camera

        // Add title text inside the plane, relative to the plane
        let titleText = createTextNode(text: "Hello World", fontSize: 10, color: .black)
        titleText.position = SCNVector3(0, 0.02, 0.05) // Slightly above the center of the plane (relative to cardNode)
//        titleText.scale = SCNVector3(0.02, 0.02, 0.02) // Scale the text to fit nicely inside the card
        cardNode.addChildNode(titleText)

        // Add description text inside the plane, relative to the plane
        let descriptionText = createTextNode(text: "How are you today? Are you ok?", fontSize: 5, color: .darkGray)
        descriptionText.position = SCNVector3(-0.06, -0.02, 0.05) // Slightly below the center of the plane (relative to cardNode)
//        descriptionText.scale = SCNVector3(0.015, 0.015, 0.015) // Adjust scale to fit description text
        cardNode.addChildNode(descriptionText)

        // Add the card node to the scene
        sceneView.scene.rootNode.addChildNode(cardNode)

    }

    private func createTextNode(text: String, fontSize: CGFloat, color: UIColor) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
        textGeometry.font = UIFont.systemFont(ofSize: fontSize)
        textGeometry.firstMaterial?.diffuse.contents = color
        textGeometry.firstMaterial?.isDoubleSided = true

        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.005, 0.005, 0.005) // Scale text appropriately
        textNode.pivot = SCNMatrix4MakeTranslation(
            Float(textGeometry.boundingBox.max.x - textGeometry.boundingBox.min.x) / -2,
            Float(textGeometry.boundingBox.max.y - textGeometry.boundingBox.min.y) / -2,
            0
        ) // Center the text
        return textNode
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        sceneView.session.pause() // Pause the session when the view is removed
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sceneView.frame = bounds
    }

    func addAxes() {
        // Define the length of each axis

        let axisLength: CGFloat = 0.1 // Adjust axis length as needed

        // Create the X-axis (Red)
        let xAxis = createAxisLine(color: .red, length: axisLength)
        xAxis.rotation = SCNVector4(1, 0, 0, Float.pi / 2)  // Rotate around X-axis (if needed)
        xAxis.position = SCNVector3(0, 0, 0)  // Position at the origin

        // Create the Y-axis (Green)
        let yAxis = createAxisLine(color: .green, length: axisLength)
        yAxis.rotation = SCNVector4(0, 1, 0, Float.pi / 2)  // Rotate around Y-axis (if needed)
        yAxis.position = SCNVector3(0, 0, 0)  // Position at the origin

        // Create the Z-axis (Blue)
        let zAxis = createAxisLine(color: .blue, length: axisLength)
        zAxis.rotation = SCNVector4(0, 0, 1, Float.pi / 2)  // Rotate around Z-axis (if needed)
        zAxis.position = SCNVector3(0, 0, 0)  // Position at the origin


        // Add axes to the scene
        sceneView.scene.rootNode.addChildNode(xAxis)
        sceneView.scene.rootNode.addChildNode(yAxis)
        sceneView.scene.rootNode.addChildNode(zAxis)
    }

    func createAxisLine(color: UIColor, length: CGFloat) -> SCNNode {
        // Create a cylinder to represent the axis line
        let cylinder = SCNCylinder(radius: 0.002, height: length)
        cylinder.firstMaterial?.diffuse.contents = color
        
        // Create a node with the cylinder geometry
        let axisNode = SCNNode(geometry: cylinder)
        axisNode.position = SCNVector3(0, 0, 0) // Start at origin
        
        return axisNode
    }


}
