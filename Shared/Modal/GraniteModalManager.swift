#if os(iOS)

import Foundation
import SwiftUI

final public class GraniteModalManager : ObservableObject {
    
    @Published var presenters = [AnyGraniteModal]()
    @Published var sheet : AnyView? = nil
    
    fileprivate var window : GraniteModalWindow? = nil

    public init(_ wrapper : @escaping ((GraniteModalContainerView) -> AnyView) = { view in AnyView(view) }) {
        
        DispatchQueue.main.async {
            self.attachWindow(wrapper)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { [weak self] _ in
            self?.attachWindow(wrapper)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.attachWindow(wrapper)
        }
    }
    
    public func present(_ modal : AnyGraniteModal) {
 
        withAnimation {
            presenters.append(modal)
        }
        
        window?.isUserInteractionEnabled = true
    }
    
    public func dismiss() {
        guard presenters.count > 0 else {
            return
        }
        
        withAnimation {
            _ = presenters.removeLast()
            
            if presenters.count == 0 {
                window?.isUserInteractionEnabled = false
            }
        }
        
    }
    
}

extension GraniteModalManager {
    
    fileprivate func attachWindow(_ wrapper : @escaping ((GraniteModalContainerView) -> AnyView)) {
        guard window == nil else {
            return
        }
        
        guard let windowScene = UIApplication.shared
                .connectedScenes
                .first as? UIWindowScene else {
            return
        }
        
        let rootView = wrapper(GraniteModalContainerView())
            .environmentObject(self)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GraniteModalWindow.PassthroughView())
            .transformEnvironment(\.graniteAlertViewStyle) { value in
                value = .init()
            }
        
        let window = GraniteModalWindow(windowScene: windowScene)
        window.windowLevel = .alert
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        window.isUserInteractionEnabled = false
        window.backgroundColor = UIColor.clear
        window.rootViewController?.view.backgroundColor = .clear
        
        self.window = window
    }
    
}

#endif
