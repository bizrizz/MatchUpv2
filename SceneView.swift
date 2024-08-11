import SwiftUI
import SceneKit

struct SceneView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene(named: "face.scnz") // Load the face model

        // Remove the mouth node if it exists
        if let mouthNode = sceneView.scene?.rootNode.childNode(withName: "mouth", recursively: true) {
            mouthNode.removeFromParentNode()
        }

        // Load and add eyes model, then duplicate it
        if let eyeNode = sceneView.scene?.rootNode.childNode(withName: "eye", recursively: true) {
            let leftEyeNode = eyeNode.clone()  // Duplicate the eye node
            leftEyeNode.position = SCNVector3(x: -1, y: 0, z: 0)  // Adjust these values based on your model's structure
            sceneView.scene?.rootNode.addChildNode(leftEyeNode)

            let rightEyeNode = eyeNode.clone()
            rightEyeNode.position = SCNVector3(x: 1, y: 0, z: 0)  // Adjust these values based on your model's structure
            sceneView.scene?.rootNode.addChildNode(rightEyeNode)
        }
        
        // Setup the camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // This function can remain empty if there are no updates to the view required after initial setup
    }
}
