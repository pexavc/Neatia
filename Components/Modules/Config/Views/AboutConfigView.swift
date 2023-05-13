//
//  AboutConfigView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/5/23.
//

import Foundation
import SwiftUI
import Granite

struct AboutConfigView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("About")
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
