import SwiftUI

struct FeatureImageSliderView: View {
    
    struct Item: Identifiable {
        let id = UUID()
        let image: Image
    }
    
    static var images = ["0", "1", "2", "3", "4"]
    let items: [Item] = FeatureImageSliderView.images.map { Item(image: Image("featureImages/\($0)")) }
    
    var body: some View {
        ACarousel(items) { item in
            VisualEffectBackground(overlayColor: Color.purple.opacity(0.5))
                .frame(height: 180)
                .overlay(item.image
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(x: item.id != items[0].id ? 0.9 : 1,
                                 y: item.id != items[0].id ? 0.9 : 1))
                .clipShape(RoundedRectangle(cornerRadius: 30,
                    style: .continuous))
                .shadow(radius: 9)
        }
        .frame(height: 200)
    }
}
