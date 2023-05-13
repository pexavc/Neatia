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
    @Published var isVisible: Bool = false
    
    public func toggle() {
        isVisible.toggle()
    }
    
    public func open() {
        isVisible = true
    }
    
    public func close() {
        isVisible = false
    }
}

final class WindowVisibilityManager: Equatable, SharableObject {
    static func == (lhs: WindowVisibilityManager, rhs: WindowVisibilityManager) -> Bool {
        lhs.kit.isVisible == rhs.kit.isVisible
    }
    
    public static var initialValue: WindowVisibilityManager {
        .init()
    }
    
    public let id : UUID = .init()
    
    internal var cancellables = Set<AnyCancellable>()
    
    let kit: WindowVisibilityKit
    
    init() {
        kit = .init()
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
    
    public func toggle() {
        DispatchQueue.main.async {
            self.kit.toggle()
        }
    }
    
    public var isVisible: Bool {
        kit.isVisible
    }
    
    public func open() {
        DispatchQueue.main.async {
            self.kit.open()
        }
    }
    
    public func close() {
        DispatchQueue.main.async {
            self.kit.close()
        }
    }
}
