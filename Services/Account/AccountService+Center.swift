import Granite
import SwiftUI

extension AccountService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var nonce: String = ""
            var isLoggedIn: Bool = false {
                didSet {
                    print("[AccountService] Logged in status: \(isLoggedIn)")
                }
            }
            var isSubscribed: Bool = false {
                didSet {
                    print("[AccountService] Subscription status: \(isLoggedIn)")
                }
            }
            
            var isLocked: Bool {
                isLoggedIn == false || isSubscribed == false
            }
        }
        
        @Event var checkLogin: CheckLoginStatus.Reducer
        @Event var login: Login.Reducer
        @Event var logout: Logout.Reducer
        @Event var subscribe: Subscribe.Reducer
        
        @Store public var state: State
    }
}
