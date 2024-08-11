import SwiftUI
import SceneKit

struct AvatarCustomizationView: View {
    @State private var skinColor = Color.yellow  // Initial skin color
    @State private var eyeColor = Color.white    // Initial eye color

    var body: some View {
        VStack {
            SceneView()  // Ensure this view can access the skinColor and eyeColor states
                .frame(height: 300)
            
            ColorPicker("Skin Color", selection: $skinColor, supportsOpacity: false)
                .onChange(of: skinColor) { newValue in
                    updateColor(nodeName: "face", color: UIColor(newValue))
                }
            ColorPicker("Eye Color", selection: $eyeColor, supportsOpacity: false)
                .onChange(of: eyeColor) { newValue in
                    updateColor(nodeName: "eye", color: UIColor(newValue))
                }
            Button("Save Changes") {
                // Logic to save changes can be implemented here
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    func updateColor(nodeName: String, color: UIColor) {
        guard let sceneView = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController?.view as? SCNView else { return }
        let nodes = sceneView.scene?.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            node.name?.contains(nodeName) ?? false
        })
        nodes?.forEach { node in
            node.geometry?.firstMaterial?.diffuse.contents = color
        }
    }
}

struct AvatarCustomizationView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarCustomizationView()
    }
}
