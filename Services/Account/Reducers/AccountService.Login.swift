import Granite
import AuthenticationServices
import FirebaseAuth
import SwiftyStoreKit

extension AccountService {
    struct CheckLoginStatus: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Relay var environment: EnvironmentService
        
        @Event var subscriptionCheck: CheckSubscriptionStatus.Reducer
        
        func reduce(state: inout Center.State) {
            
            if let user = Auth.auth().currentUser {
                state.isLoggedIn = true
                subscriptionCheck.send()
            } else {
                state.isLoggedIn = false
                environment
                    .center
                    .interact
                    .send(
                        EnvironmentService
                            .Interact
                            .Meta(interaction: .disable))
            }
        }
    }
    
    struct Login: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var authResults: ASAuthorization? = nil
        }
        
        @Payload var meta: Meta?
        
        @Event var complete: LoginComplete.Reducer
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta,
                  let authResults = meta.authResults else {
                return
            }
            
            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    return
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: state.nonce)
                
                
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if (error != nil) {
                        print(error?.localizedDescription as Any)
                    } else {
                        complete.send(LoginComplete.Meta(authDataResult: authResult))
                    }
                }
            }
        }
    }
    
    struct LoginComplete: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var authDataResult: AuthDataResult? = nil
        }
        
//        @Relay var environment: EnvironmentService
        
        @Event var subscriptionCheck: CheckSubscriptionStatus.Reducer
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let result = self.meta?.authDataResult else { return }
            
//            environment
//                .center
//                .interact
//                .send(
//                    EnvironmentService
//                        .Interact
//                        .Meta(interaction: .enable))
            
            state.isLoggedIn = true
            subscriptionCheck.send()
        }
        
    }
}
