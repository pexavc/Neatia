//
//  Mount.Views.Paywall.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/6/23.
//


import Granite
import SwiftUI

extension Mount {
    var paywallView: some View {
        Group {
//            MacEditorTextView(
//                text: .constant("You must subscribe to use this service."),
//                isEditable: false,
//                font: NSFont(name: "Menlo-Regular", size: 16)
//            )
//            .frame(maxWidth: .infinity,
//                   minHeight: 48,
//                   maxHeight: .infinity)
//            .padding(.leading, 4)
//            .opacity(0.75)
//
            
            if account.state.isLocked {
                Brand.Colors.black
                    .opacity(0.5)
                
                Button(account.center.subscribe) {
                    Text("Subscribe")
                }
            }
        }
    }
}
