import Granite
import SwiftUI
import VaultKit

extension AccountService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var nonce: String = ""
            var isLoggedIn: Bool = false {
                didSet {
                    print("[AccountService] Logged in status: \(isLoggedIn)")
                }
            }
            
            var isLocked: Bool {
                isLoggedIn == false
            }
        }
        
        @Event var checkLogin: CheckLoginStatus.Reducer
        @Event var login: Login.Reducer
        @Event var logout: Logout.Reducer
        @Event var subscribe: Subscribe.Reducer
        
        @Store(persist: "neatia.persistence.account.0001", autoSave: true) public var state: State
    }
}
