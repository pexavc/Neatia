//
//  SessionManager.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/13/23.
//

import Foundation
import Granite
import Combine
import VaultKit

class SessionManagerKit {
    @Published var isLoggedIn: Bool = false
    @Published var isSubscribed: Bool = false
    @Published var isLifetimeAPI: Bool = false
    @Published var isCustomAPI: Bool = false
    
    public func isLoggedIn(_ state: Bool) {
        isLoggedIn = state
    }
    
    public func isSubscribed(_ state: Bool) {
        isSubscribed = state
    }
    
    public func isLifetimeAPI(_ state: Bool) {
        isLifetimeAPI = state
    }
    
    public func isCustomAPI(_ state: Bool) {
        isCustomAPI = state
    }
}

final class SessionManager: Equatable, SharableObject {
    static func == (lhs: SessionManager, rhs: SessionManager) -> Bool {
        lhs.kit.isLoggedIn == rhs.kit.isLoggedIn &&
        lhs.kit.isSubscribed == rhs.kit.isSubscribed &&
        lhs.kit.isCustomAPI == rhs.kit.isCustomAPI
    }
    
    public static var initialValue: SessionManager {
        .init()
    }
    
    public static var id : String = "nyc.stoic.Neatia.SessionManager"
    
    internal var cancellables = Set<AnyCancellable>()
    
    var isLocked: Bool {
//        print("[SessionManager] isLocked: \(kit.isLifetimeAPI), \(kit.isCustomAPI), \(kit.isSubscribed)")
        if kit.isLifetimeAPI {
            return kit.isCustomAPI == false
        } else {
            return kit.isSubscribed == false || kit.isLoggedIn == false
        }
    }
    
    var isLoggedIn: Bool {
        kit.isLoggedIn
    }
    
    var isSubscribed: Bool {
        kit.isSubscribed
    }
    
    var isLifetimeAPI: Bool {
        kit.isLifetimeAPI
    }
    
    let kit: SessionManagerKit
    
    init() {
        kit = .init()
        observe()
    }
    
    private func observe() {
        kit.$isLoggedIn
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        kit.$isSubscribed
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        kit.$isLifetimeAPI
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    public func isLoggedIn(_ state: Bool) {
        kit.isLoggedIn = state
    }
    
    public func isSubscribed(_ state: Bool) {
        kit.isSubscribed = state
    }
    
    public func isLifetimeAPI(_ state: Bool) {
        kit.isLifetimeAPI = state
    }
    
    public func isCustomAPI(_ state: Bool) {
        kit.isCustomAPI = state
    }
    
    public func checkSubscription() {
        kit.isSubscribed = VaultManager.isSubscribed
    }
    
    public func checkLifetimeAPI() {
        kit.isLifetimeAPI = VaultManager.purchased(VaultProducts.Lifetime.basic)
    }
}
