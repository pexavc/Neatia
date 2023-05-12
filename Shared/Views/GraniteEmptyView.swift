//
//  GraniteEmptyView.swift
//  Stoic
//
//  Created by PEXAVC on 1/3/23.
//

import Foundation
import SwiftUI

struct GraniteEmptyView: View {
    var text: LocalizedStringKey = ""
    var gradients: [Color] = [Brand.Colors.marbleV2, Brand.Colors.marble]
    
    public var body: some View {
        GraniteDisclaimerView(text,
                              gradientColors: gradients)
    }
}
