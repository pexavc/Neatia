//
//  ShortcutConfigView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/11/23.
//

import Foundation
import SwiftUI
import Granite

struct ShortcutConfigView: View {
    
    @Relay var config: ConfigService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Shortcuts")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            Text("Main Window Activation")
                .font(Fonts.live(.headline, .bold))
                .foregroundColor(.foreground)
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
                            VStack {
                                Spacer()
                                Text(item.rawValue.uppercased())
                                    .font(Fonts.live(.subheadline, .bold))
                                Spacer()
                            }
                        }
                    }
                } label: {
                    Text(config.state.mountHotkey.rawValue.uppercased())
                        .font(Fonts.live(.subheadline, .bold))
                }
                .frame(maxWidth: 60)
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}
