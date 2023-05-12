//
//  PromptsConfigView.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/11/23.
//

import Foundation
import SwiftUI
import Granite

struct PromptConfigView: View {
    
    @Relay var config: ConfigService
    
    var body: some View {
        HStack {
            Image(systemName: "option")
                .font(.defaultFont)
            
            Text("+")
                .font(.defaultFont)
            
            Menu {
                ForEach(InteractionManager.HotkeyOptions.allCases, id: \.self) { item in
                    
                    Button {
                        config
                            .center
                            .updateHotkey
                            .send(ConfigService.Hotkey.Meta(key: item))
                    } label: {
                        Text(item.rawValue.uppercased())
                            .font(.defaultFont)
                    }
                }
            } label: {
                Text(config.state.mountHotkey.rawValue.uppercased())
                    .font(.defaultFont)
            }
        }
        .padding(8)
    }
}
