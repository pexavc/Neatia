import SwiftUI

struct FeatureImageSliderView: View {
    
    struct Item: Identifiable {
        let id = UUID()
        let image: Image
    }
    
    static var images = ["0", "1", "2", "3", "4", "5"]
    let items: [Item] = FeatureImageSliderView.images.map { Item(image: Image("featureImages/\($0)")) }
    
    var body: some View {
        ACarousel(items) { item in
            VisualEffectBackground(overlayColor: Color.purple.opacity(0.5))
                .frame(height: 260)
                .overlay(item.image
                    .resizable()
                    .scaledToFill())
                .clipShape(RoundedRectangle(cornerRadius: 24,
                    style: .continuous))
                .shadow(radius: 9)
        }
        .frame(height: 280)
    }
}
