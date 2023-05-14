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

struct CustomCommand: GraniteModel, Identifiable {
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
         creativity: Double?) {
        
        self.command = command
        self.prompt = prompt
        self.iconName = iconName
        self.baseColorHex = baseColorHex
        self.description = description
        self.dateCreated = .init()
        self.creativity = creativity
    }
}

extension CustomPrompt {
    var baseColor: Color {
        .init(hex: baseColorHex)
    }
    
    public var isSystemPrompt: Bool { false }
}
