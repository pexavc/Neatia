import Foundation
import SwiftUI

final public class GraniteSheetManager : ObservableObject {
    
    var style : GraniteSheetPresentationStyle = .sheet
    
    @Published var content : AnyView? = nil
    @Published public var shouldPreventDismissal : Bool = false
    
    public init() {
        
    }
    
    func hasContent(with style : GraniteSheetPresentationStyle) -> Binding<Bool> {
        .init(get: {
            self.content != nil && self.style == style
        }, set: { value in
            if value == false {
                self.content = nil
            }
        })
    }
    
    public func present<Content : View>(@ViewBuilder content : () -> Content, style : GraniteSheetPresentationStyle = .sheet) {
        self.style = style
        self.content = AnyView(content())
    }
    
    public func dismiss() {
        content = nil
        shouldPreventDismissal = false
    }
    
}
