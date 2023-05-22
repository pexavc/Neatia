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
        
        func reduce(state: inout Center.State) {
            try? Auth.auth().signOut()
            
            AccountManager.logout()
        }
    }
}
