//
//  PaneKit.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/8/23.
//

import Foundation
import Combine
import SwiftUI

class PaneKit<Content: View>: Equatable, Codable {
    static func == (lhs: PaneKit, rhs: PaneKit) -> Bool {
        lhs.id == rhs.id
    }
    
    private(set) var isPrepared: Bool = false
    private var requiresUpdate: Bool = false
    internal var cancellables = Set<AnyCancellable>()
    
    internal var componentStorage: [WindowComponent : CGSize] = [ : ]
    
    let id: UUID = .init()
    let window: PaneKit.Window
    let defaultSize: CGSize
    let content: () -> Content
    
    init(defaultSize: CGSize, @ViewBuilder content : (@escaping () -> Content)) {
        window = .init(size: defaultSize, maxSize: WindowComponent.Style.maxWindowSize)
        self.defaultSize = defaultSize
        self.content = content
    }
    
    func build() {
        if window.isPrepared == false {
            window.$isPrepared.removeDuplicates()
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    self?.isPrepared = state
                    
                    self?.host()
                    
                    if self?.requiresUpdate == true {
                        //Post update needs
                        self?.requiresUpdate = false
                    }
            }.store(in: &cancellables)
            window.build()
        } else {
            self.isPrepared = true
        }
    }
    
    private func host() {
        window.setHost(NSHostingController(rootView: content()))
    }
    
    func toggleWindow() {
        window.toggle()
    }
    
    enum CodingKeys: CodingKey {
        case id
        case isPrepared
        case defaultSize
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(isPrepared, forKey: .isPrepared)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try? container.decode(UUID.self, forKey: .id)
        let defaultSize = try? container.decode(CGSize.self, forKey: .defaultSize)
        
        self.init(defaultSize: defaultSize ?? .zero) { EmptyView() as! Content }
    }
}

