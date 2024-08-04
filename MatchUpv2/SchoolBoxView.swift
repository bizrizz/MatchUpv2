import SwiftUI
import CoreLocation

struct SchoolBoxView: View {
    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
    var navigateToLocation: (CLLocationCoordinate2D) -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: {
            navigateToLocation(coordinate)
        }) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.black)
            }
            .padding()
            .frame(width: isHovering ? 380 : 370, height: isHovering ? 180 : 170)
            .background(
                ZStack {
                    Color.gray.opacity(0.9)
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                }
            )
            .cornerRadius(10)
            .onHover { hover in
                withAnimation(.easeInOut) {
                    isHovering = hover
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 5)
    }
}

// VisualEffectView wrapper for UIBlurEffect
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}
