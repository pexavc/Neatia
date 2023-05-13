//
//  Account.Logout.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/5/23.
//

import Granite
import AuthenticationServices
import FirebaseAuth

extension AccountService {
    struct Logout: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Relay var environment: EnvironmentService
        
        func reduce(state: inout Center.State) {
            environment
                .center
                .interact
                .send(
                    EnvironmentService
                        .Interact
                        .Meta(interaction: .disable))
            
            state.isLoggedIn = false
            try? Auth.auth().signOut()
        }
    }
}
