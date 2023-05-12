//
//  AccountConfigView.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/5/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct AccountConfigView: View {
    @GraniteAction<Void> var subscribe
    @GraniteAction<Void> var logout
    
    @Relay var account: AccountService
    
    var body: some View {
        VStack(alignment: .leading) {
            if account.state.isSubscribed {
                standardView
            } else {
                paywallView
            }
        }
        .padding(8)
    }
    
    var standardView: some View {
        Group {
            VStack {
                
            }
        }
    }
    
    var paywallView: some View {
        Group {
            HStack {
                AppBlurView(size: .init(0, 240),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    VStack(alignment: .leading) {
                        Text("Subscription: $12.99/mo")
                            .font(Fonts.live(.title2, .bold))
                            .foregroundColor(.foreground)
                        
                        Text("w/ 3 day free trial")
                            .font(Fonts.live(.title3, .regular))
                            .foregroundColor(.foreground)
                        
                        Spacer().frame(height: 8)
                        
                        Text("• Full Access")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Access to all custom prompt engineered templates")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Create and re-use custom prompts")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Share and use prompts with the custom extension")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• New prompts each update with features curated from your feedback")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                    }
                }
                .padding(.trailing, 16)
                .frame(height: 240)
                .environment(\.colorScheme, .dark)
                
                Spacer()
            }
            
            AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                
                Text("Subscribe")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
            }
            .environment(\.colorScheme, .dark)
            .onTapGesture {
                subscribe.perform()
            }
        }
    }
}
