//
//  PromptsConfigView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/11/23.
//

import Foundation
import SwiftUI
import Granite

struct PromptConfigView: View {
    
    @Relay var config: ConfigService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Prompts")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}
