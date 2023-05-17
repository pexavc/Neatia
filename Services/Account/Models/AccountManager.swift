//
//  AccountManager.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/12/23.
//

import Foundation
import FirebaseAuth
import Combine
import Granite

class AccountKit {
    private(set) var id: String? = nil {
        didSet {
            isLoggedIn = id != nil
        }
    }
    
    @Published var isLoggedIn: Bool = false
    @Published var isSubscribed: Bool = false
    
    init() {
        self.id = nil
    }
    
    func load(_ user: User) {
        self.id = user.uid
    }
    
    func isSubscribed(_ state: Bool) {
        self.isSubscribed = state
    }
    
    func logout() {
        self.id = nil
    }
}

public class AccountManager: ObservableObject {
    static let shared: AccountManager = .init()
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
    internal var cancellables = Set<AnyCancellable>()
    
    let kit: AccountKit
    
    init() {
        kit = .init()
        observe()
    }
    
    private func observe() {
        kit.$isLoggedIn
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                
            print("[AccountManager] isLoggedIn Changed: \(newValue)")
            self?.objectWillChange.send()
            self?.session.isLoggedIn(newValue)
        }.store(in: &cancellables)
        
        kit.$isSubscribed
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                
            print("[AccountManager] isSubscribed Changed: \(newValue)")
            self?.objectWillChange.send()
            self?.session.isSubscribed(newValue)
        }.store(in: &cancellables)
    }
    
    public static func load(_ user: User) {
        AccountManager.shared.kit.load(user)
    }
    
    public static func logout() {
        AccountManager.shared.kit.logout()
    }
    
    public static var isLoggedIn: Bool {
        AccountManager.shared.kit.isLoggedIn
    }
    
    public static func isSubscribed(_ state: Bool) {
        AccountManager.shared.kit.isSubscribed(state)
    }
}
