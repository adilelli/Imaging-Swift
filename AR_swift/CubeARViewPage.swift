//
//  CubeARViewPage.swift
//  AR_swift
//
//  Created by Adil Elli on 25/10/2024.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

struct CubeARViewPage: UIViewRepresentable {
    // The AR view to present
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()

        // Run the AR session
        arView.session.run(configuration)

        // Add a cube to the scene
        addCube(to: arView)

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    // Function to add a cube to the AR scene
    private func addCube(to arView: ARSCNView) {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue // Change color as needed
        cube.materials = [material]

        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(0, 0, -0.5) // Position it 0.5 meters in front of the camera

        // Add the cube node to the scene
        arView.scene.rootNode.addChildNode(cubeNode)
    }
}

struct CubeARViewPage_Previews: PreviewProvider {
    static var previews: some View {
        CubeARViewPage()
            .edgesIgnoringSafeArea(.all)
    }
}
