//
//  AccountConfigView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/5/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import VaultKit

struct AccountConfigView: View {
    @GraniteAction<Void> var subscribe
    @GraniteAction<Void> var logout
    
    @Relay var account: AccountService
    
    @State var selectedOption: VaultProduct? = VaultManager.shared.renewableProducts.first
    
    @State var nonRenewable: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if VaultManager.isSubscribed {
                standardView
            } else {
                paywallView
            }
        }
        .padding(8)
    }
    
    var standardView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                if let purchase = VaultManager.currentPurchase {
                    subscriptionStats(purchase)
                        .frame(maxWidth: .infinity)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    var paywallView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                Text("Get Access")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                AppBlurView(size: .init(0, 200),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("• Templated shortcuts to get GPT backed answers at speed.")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Store outputs, locally in-app, to recall later or download reponses as PDFs.")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Re-word resumes or generate cover letters.")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Easily accessible with a command and no personal data is stored or shared.")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• And much more...")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                    }
                }
                .frame(height: 200)
                .environment(\.colorScheme, .dark)
                
                Spacer().frame(height: 8)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                if nonRenewable {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Non-Renewable")
                            .font(Fonts.live(.title3, .bold))
                            .foregroundColor(.foreground)
                        
                        HStack(spacing: 8) {
                            ForEach(VaultManager.nonRenewableProducts.ordered) { product in
                                optionView(product)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Renewable")
                            .font(Fonts.live(.title3, .bold))
                            .foregroundColor(.foreground)
                        
                        ForEach(VaultManager.renewableProducts.ordered) { product in
                            
                            optionView(product)
                        }
                    }
                }
                
                Toggle("Non-renewable", isOn: $nonRenewable)
                    .onChange(of: nonRenewable) { newState in
                        
                        if newState {
                            selectedOption = VaultManager.shared.nonRenewableProducts.first
                        } else {
                            selectedOption = VaultManager.shared.renewableProducts.first
                        }
                    }
                
                AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                    
                    HStack(spacing: 8) {
                        
                        Button(action: {
                            account
                                .center
                                .subscribe
                                .send(AccountService.Subscribe.Meta(product: selectedOption))
                        }) {
                            
                            Text(nonRenewable ? "Purchase" : "Subscribe")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                            
                            Text(selectedOption?.metadata.displayPrice ?? "")
                                .font(Fonts.live(.footnote, .regular))
                                .foregroundColor(.foreground) + Text(selectedOption?.metadata.isRenewable == true ? "/mo" : "")
                                .font(Fonts.live(.footnote, .regular))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .environment(\.colorScheme, .dark)
            }
        }
    }
    
    func optionView(_ product: VaultProduct) -> some View {
        AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
            HStack(spacing: 8) {
                Text(product.metadata.displayName.replacingOccurrences(of: " Access", with: ""))
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
//                Text(metadata.displayPrice)
//                    .font(Fonts.live(.footnote, .regular))
//                    .foregroundColor(.foreground)
                
                if selectedOption == product {
                    Image(systemName: "checkmark")
                        .frame(width: 12, height: 12)
                        .foregroundColor(.foreground)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .onTapGesture {
            selectedOption = product
        }
    }
}

extension AccountConfigView {
    func subscriptionStats(_ currentPurchase: VaultActiveProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Subscription Status")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            
            AppBlurView(size: .init(0, 80),
                        tintColor: Brand.Colors.black.opacity(0.3)) {
                VStack(alignment: .leading, spacing: 8) {
                    if let date = currentPurchase.expirationDate {
                        Text("Expiration Date: \(date.asString)")
                            .font(Fonts.live(.headline, .regular))
                            .foregroundColor(.foreground)
                    }
                    
                    Text("Purchase Date: \(currentPurchase.purchaseDate.asString)")
                        .font(Fonts.live(.headline, .regular))
                        .foregroundColor(.foreground)
                    
                    Text("Renews: \(currentPurchase.isRenewable ? "Yes" : "No")")
                        .font(Fonts.live(.headline, .regular))
                        .foregroundColor(.foreground)
                }
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
