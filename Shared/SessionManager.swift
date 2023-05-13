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
    
    public func isLoggedIn(_ state: Bool) {
        isLoggedIn = state
    }
    
    public func isSubscribed(_ state: Bool) {
        isSubscribed = state
    }
}

final class SessionManager: Equatable, SharableObject {
    static func == (lhs: SessionManager, rhs: SessionManager) -> Bool {
        lhs.kit.isLoggedIn == rhs.kit.isLoggedIn &&
        lhs.kit.isSubscribed == rhs.kit.isSubscribed
    }
    
    public static var initialValue: SessionManager {
        .init()
    }
    
    public let id : String = "nys.stoic.Neatia.SessionManager"
    
    internal var cancellables = Set<AnyCancellable>()
    
    var isLocked: Bool {
        kit.isSubscribed == false || kit.isLoggedIn == false
    }
    
    var isLoggedIn: Bool {
        kit.isLoggedIn
    }
    
    var isSubscribed: Bool {
        kit.isSubscribed
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
    }
    
    public func isLoggedIn(_ state: Bool) {
        kit.isLoggedIn = state
    }
    
    public func isSubscribed(_ state: Bool) {
        kit.isSubscribed = state
    }
    
    public func checkSubscription() {
        kit.isSubscribed = VaultManager.isSubscribed
    }
}
