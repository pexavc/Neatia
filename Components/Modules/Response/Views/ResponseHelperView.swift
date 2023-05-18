//
//  ResponseHelperView.swift
//  Neatia (iOS)
//
//  Created by Ritesh Pakala on 5/17/23.
//

import Foundation
import SwiftUI
import Granite

protocol BasicHelper: Identifiable {
    var kind: HelperInfo.Kind { get }
}

extension BasicHelper {
    var id: String { kind.description }
}

struct HelperInfo: BasicHelper, GraniteModel {
    enum Kind: GraniteModel {
        case color(String)
        
        var description: String {
            switch self {
            case .color(let hex):
                return "color:\(hex)"
            }
        }
    }
    
    let kind: Kind
    
    static func generate(from response: String) -> [HelperInfo] {
        var info: [HelperInfo] = []
        for match in response.match("#(([0-9a-fA-F]{2}){3,4}|([0-9a-fA-F]){3,4})") {
            if match.value.contains("#") {
                info.append(.init(kind: .color(match.value)))
            }
        }
        
        return info
    }
}

struct ResponseHelperView: View {
    
    var helperInfo: [HelperInfo]
    
    var width: CGFloat = 200
    
    @State var open: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            HStack{
                Spacer()
                
                AppBlurView(size: .init(24, WindowComponent.Style.defaultElementSize.height),
                            padding: .init(8, 0),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    Button {
                        open.toggle()
                    } label : {
                        Image(systemName: "arrow.\(open ? "right" : "left").square.fill")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: 24, height: WindowComponent.Style.defaultElementSize.height)
                
                AppBlurView(size: .init(0, geo.size.height - WindowComponent.Style.defaultComponentOuterPaddingContainerAware * 2),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    ScrollView([.vertical], showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(helperInfo) { info in
                                switch info.kind {
                                case .color(let hex):
                                    VStack(spacing: 8) {
                                        Circle()
                                            .foregroundColor(Color(hex: hex))
                                            .frame(width: 120, height: 120)
                                        Text(hex)
                                            .foregroundColor(.foreground)
                                            .font(Fonts.live(.footnote, .bold))
                                    }
                                }
                            }
                        }.padding(.vertical, 16)
                    }
                    .frame(width: open ? width : 0, height: geo.size.height - WindowComponent.Style.defaultComponentOuterPaddingContainerAware * 2)
                    .padding(.leading, 4)
                }
                .offset(x: -4)
                .frame(width: open ? width : 0, height: geo.size.height - WindowComponent.Style.defaultComponentOuterPaddingContainerAware * 2)
                .opacity(open ? 1.0 : 0.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(Animation.easeIn(duration: 0.3), value: open)
        }
    }
}
