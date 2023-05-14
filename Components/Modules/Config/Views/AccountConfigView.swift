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
    
    @State var selectedOption: VaultProduct? = VaultManager.shared.productFor(VaultProducts.Renewable.monthly)
    
//    @State var nonRenewable: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if VaultManager.isSubscribed {
                standardView
            } else {
                paywallView
            }
        }
        .padding(16)
    }
    
    var standardView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Account")
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                if let purchase = VaultManager.currentPurchase {
                    subscriptionStats(purchase)
                        .frame(maxWidth: .infinity)
                }
                
                Spacer()
            }
        }
    }
    
    var paywallView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Get Access")
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                }
                
                AppBlurView(size: .init(0, 240),
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
                .frame(height: 240)
                .environment(\.colorScheme, .dark)
                
                Spacer()
                
                
                Text("Subscription Plans")
                    .font(Fonts.live(.title3, .bold))
                    .foregroundColor(.foreground)
                
                HStack(spacing: 8) {
                    ForEach(VaultManager.renewableProducts.ordered) { product in
                        
                        optionView(product)
                    }
                }
                
                AppBlurView(tintColor: Brand.Colors.yellow.opacity(0.45)) {
                    
                    HStack(spacing: 8) {
                        
                        Button(action: {
                            account
                                .center
                                .subscribe
                                .send(AccountService.Subscribe.Meta(product: selectedOption))
                        }) {
                            
                            //                            Text(nonRenewable ? "Purchase" : "Subscribe")
                            Text("Subscribe")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                            
                            Text(selectedOption?.metadata.displayPrice ?? "")
                                .font(Fonts.live(.footnote, .regular))
                                .foregroundColor(.foreground) + //Text(selectedOption?.metadata.isRenewable == true ? "/mo" : "")
                            Text(selectedOption?.metadata.displaySubscriptionPeriod ?? "")
                                .font(Fonts.live(.footnote, .regular))
                                .foregroundColor(.foreground) +
                            Text(selectedOption?.metadata.displayPromo.isEmpty == true ? "" : " " + (selectedOption?.metadata.displayPromo ?? ""))
                                .font(Fonts.live(.caption2, .regular))
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
                Text(product.metadata.displayName.replacingOccurrences(of: " Subscription", with: ""))
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
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            
            AppBlurView(size: .init(0, 90),
                        tintColor: Brand.Colors.black.opacity(0.3)) {
                VStack(alignment: .leading, spacing: 8) {
                    if let date = currentPurchase.expirationDate {
                        Text("Expiration Date: ")
                            .font(Fonts.live(.subheadline, .bold))
                            .foregroundColor(.foreground) + Text(date.asString)
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                    }
                    
                    Text("Purchase Date: ")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground) + Text(currentPurchase.purchaseDate.asString)
                        .font(Fonts.live(.subheadline, .regular))
                        .foregroundColor(.foreground)
                    
                    Text("Renews: ")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground) + Text("\(currentPurchase.isRenewable ? "Yes" : "No")")
                        .font(Fonts.live(.subheadline, .regular))
                        .foregroundColor(.foreground)
                }
            }
            .environment(\.colorScheme, .dark)
            .frame(height: 90)
        }
    }
}
