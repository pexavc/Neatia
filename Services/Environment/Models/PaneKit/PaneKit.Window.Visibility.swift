//
//  PaneKit.Visibility.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/13/23.
//

import Foundation
import Combine
import Granite

class WindowVisibilityKit {
    @Published var isVisible: [String:Bool] = [:]
    
    public init(ids: [String]) {
        for id in ids {
            isVisible[id] = false
        }
    }
    
    public func toggle(_ id: String) {
        isVisible[id] = isVisible[id] == true ? false : true
    }
    
    public func open(_ id: String) {
        isVisible[id] = true
    }
    
    public func close(_ id: String) {
        isVisible[id] = false
    }
}

final class WindowVisibilityManager: Equatable, SharableObject {
    static func == (lhs: WindowVisibilityManager, rhs: WindowVisibilityManager) -> Bool {
        lhs.kit.isVisible == rhs.kit.isVisible
    }
    
    public static var initialValue: WindowVisibilityManager {
        .init()
    }
    
    public static var id : String = "nyc.stoic.Neatia.WindowVisibilityManager"
    
    internal var cancellables = Set<AnyCancellable>()
    
    let kit: WindowVisibilityKit
    
    init() {
        kit = .init(ids: InteractionManager.Kind.allCases.map { $0.rawValue })
        observe()
    }
    
    private func observe() {
        kit.$isVisible
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    public func toggle(id: String) {
        DispatchQueue.main.async {
            self.kit.toggle(id)
        }
    }
    
    public func isVisible(id: String) -> Bool {
        kit.isVisible[id] == true
    }
    
    public func open(id: String) {
        DispatchQueue.main.async {
            self.kit.open(id)
        }
    }
    
    public func close(id: String) {
        DispatchQueue.main.async {
            self.kit.close(id)
        }
    }
}
