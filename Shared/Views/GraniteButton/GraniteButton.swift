import SwiftUI
import Granite

public enum GraniteButtonType {
    case text(LocalizedStringKey)
    case image(String)
    case imageSystem(String)
    case add
    case addNoSeperator
}

struct GraniteButton: View {
    @Environment(\.graniteTabSelected) var isTabSelected
    
    let type: GraniteButtonType
    let selected: Bool
    let padding: EdgeInsets
    let size: CGSize
    let selectionColor: Color
    
    let textColor: Color
    let textColors: [Color]
    let textShadow: Color
    
    let action: (() -> Void)?
    
    public init(_ text: LocalizedStringKey,
                textColor: Color = Brand.Colors.black,
                colors: [Color] = [Brand.Colors.marbleV2,
                                   Brand.Colors.marble.opacity(0.42)],
                shadow: Color = Color.black.opacity(0.57),
                padding: EdgeInsets = .init(Brand.Padding.large,
                                            Brand.Padding.medium,
                                            Brand.Padding.large,
                                            Brand.Padding.medium) ,
                _ action: (() -> Void)? = nil) {
        self.type = .text(text)
        self.selected = false
        self.size = .zero
        self.selectionColor = .black
        self.padding = padding
        self.action = action
        
        self.textColor = textColor
        self.textColors = colors
        self.textShadow = shadow
        
    }
    
    public init(_ type: GraniteButtonType,
                colors: [Color] = [Brand.Colors.marbleV2,
                                   Brand.Colors.marble],
                selected: Bool = false,
                size: CGSize = .zero,
                selectionColor: Color = .black,
                padding: EdgeInsets = .init(0, 0, 0, 0),
                _ action: (() -> Void)? = nil) {
        self.type = type
        self.size = size
        self.selectionColor = selectionColor
        self.selected = selected
        self.padding = padding
        self.action = action
        
        self.textColor = Brand.Colors.black
        self.textColors = colors
        self.textShadow = Brand.Colors.black.opacity(0.57)
        
//        [Brand.Colors.marbleV2.opacity(0.66),
//                           Brand.Colors.marble]
    }
    
    init() {
        type = .text("")
        self.selected = false
        self.size = .zero
        self.selectionColor = .black
        self.padding = .init(Brand.Padding.large,
                             Brand.Padding.medium,
                             Brand.Padding.large,
                             Brand.Padding.medium)
        self.action = nil
        
        self.textColor = Brand.Colors.black
        self.textColors = [Brand.Colors.marbleV2.opacity(0.66), Brand.Colors.marble]
        self.textShadow = Brand.Colors.black.opacity(0.57)
    }
    
    var body: some View {
        VStack {
            switch type {
            case .text(let text):
                BasicButton(text: text,
                            textColor: textColor,
                            colors: textColors,
                            shadow: textShadow)
            case .imageSystem(let name):
                Image(systemName: name)
                    .renderingMode(.template)
                    .font(Font.system(size: max(size.width, size.height), weight: .semibold))
                    .frame(width: size.width,
                           height: size.height,
                           alignment: .center)
                    .contentShape(Rectangle())
                    .applyGradient(selected: isTabSelected ?? selected, colors: textColors)
            case .image(let name):
                Image(name)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: size.width,
                           height: size.height,
                           alignment: .leading)
                    .contentShape(Rectangle())
                    .applyGradient(selected: isTabSelected ?? selected, colors: textColors)
            case .add, .addNoSeperator:
                VStack(spacing: 0) {
                    if case .add = type {
                        PaddingVertical(Brand.Padding.xSmall)
                    }
                    Circle()
                        .foregroundColor(Brand.Colors.marble).overlay(
                            
                            GraniteText("+", Brand.Colors.black,
                                        .headline,
                                        .bold)
                            
                            
                        ).frame(width: 24, height: 24)
                        .padding(.top, Brand.Padding.medium)
                        .padding(.leading, Brand.Padding.small)
                        .padding(.trailing, Brand.Padding.small)
                        .padding(.bottom, Brand.Padding.medium)
                        .shadow(color: Color.black.opacity(0.75), radius: 1, x: 1, y: 1)
                }
            }
        }
        .padding(.top, padding.top)
        .padding(.leading, padding.leading)
        .padding(.trailing, padding.trailing)
        .padding(.bottom, padding.bottom)
        //.modifier(TapAndLongPressModifier(tapAction: { action?() }))
    }
}
