import SwiftUI

struct BasicButton: View {
    var text: LocalizedStringKey
    var textColor: Color
    var colors: [Color]
    var shadow: Color
    
    var body: some View {
        HStack(alignment: .center) {
            
            ZStack {
                GradientView(colors: colors,
                             cornerRadius: 6.0,
                             direction: .topLeading).overlay(
                    
                    GraniteText(text,
                                textColor,
                                .subheadline,
                                .bold,
                                .center)
                )
                .frame(width: 120, height: WindowComponent.Style.defaultElementSize.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .shadow(color: shadow, radius: 2, x: 1, y: 1)
                
            }
        }
    }
}
