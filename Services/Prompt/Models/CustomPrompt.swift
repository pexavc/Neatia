//
//  CustomPrompt.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/13/23.
//

import Foundation
import Granite
import SandKit
import SwiftUI

struct CustomCommand: GraniteModel, Identifiable, Hashable {
    var id: String {
        command
    }
    
    var command: String
    
    init(_ command: String) {
        
        self.command = command
    }
}

struct CustomPrompt: GraniteModel, BasicPrompt, Identifiable {
    var id: String {
        dateCreated.asStringWithTime
    }
    
    var command: CustomCommand
    var prompt: String
    var iconName: String
    var baseColorHex: String
    var description: String
    var dateCreated: Date
    var creativity: Double?
    var role: String
    var customConfig: PromptConfig?
    
    var config: PromptConfig {
        .init(temperature: creativity)
    }
    
    var hasSubcommand: Bool {
        false
    }
    
    init(_ command: CustomCommand,
         prompt: String,
         iconName: String,
         baseColorHex: String,
         description: String,
         creativity: Double?,
         role: String,
         customConfig: PromptConfig?) {
        
        self.command = command
        self.prompt = prompt
        self.iconName = iconName
        self.baseColorHex = baseColorHex
        self.description = description
        self.dateCreated = .init()
        self.creativity = creativity
        self.role = role
        self.customConfig = customConfig
    }
}

extension CustomPrompt {
    var baseColor: Color {
        .init(hex: baseColorHex)
    }
    
    public var isSystemPrompt: Bool { false }
}
