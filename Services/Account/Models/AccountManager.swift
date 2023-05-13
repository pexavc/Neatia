//
//  AccountManager.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/12/23.
//

import Foundation
import FirebaseAuth
import Combine

class AccountKit {
    private(set) var id: String? = nil {
        didSet {
            isLoggedIn = id != nil
        }
    }
    
    @Published var isLoggedIn: Bool = false
    
    init() {
        self.id = nil
    }
    
    func load(_ user: User) {
        self.id = user.uid
    }
    
    func logout() {
        self.id = nil
    }
}

public class AccountManager: ObservableObject {
    static let shared: AccountManager = .init()
    
    internal var cancellables = Set<AnyCancellable>()
    
    let kit: AccountKit
    
    init() {
        kit = .init()
    }
    
    private func observe() {
        kit.$isLoggedIn
            .removeDuplicates()
            .sink { [weak self] newValue in
                
            print("[AccountManager] isLoggedIn Changed: \(newValue)")
            self?.objectWillChange.send()
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
}
