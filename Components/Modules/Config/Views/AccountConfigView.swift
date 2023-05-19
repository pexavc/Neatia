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
    
    @State var reducedPricing: Bool = false
    
    @State var viewSubscription: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            if VaultManager.isSubscribed || viewSubscription == false {
                standardView
            } else {
                paywallView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
    
    var standardView: some View {
        Group {
            HStack {
                Text("Account")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
                
                if VaultManager.isSubscribed == false {
                    AppBlurView(tintColor: Brand.Colors.yellow.opacity(0.45)) {
                        Button(action: {
                            viewSubscription = true
                        }) {
                            Text("Subscribe")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                }
            }
            .padding(.bottom, 8)
            
            if let purchase = VaultManager.currentPurchase {
                subscriptionStats(purchase)
                    .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
    }
    
    var paywallView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Free & Premium features")
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                    
                    AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button(action: {
                            viewSubscription = false
                        }) {
                            Text("Back")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                }
                
                AppBlurView(size: .init(0, 100),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("• Custom API Keys. Tune additional parameters before making queries.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Custom prompts to repeat queries at speed with a command you set.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                    }
                }
                .frame(height: 100)
                .environment(\.colorScheme, .dark)
                .padding(.bottom, 8)
                
                HStack {
                    Text("Premium features")
                        .font(Fonts.live(.headline, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                }
                
                AppBlurView(size: .init(0, 100),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("• Neatia engineered prompts and tuning. They update or new ones get added weekly.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Extended featureset for custom prompts in Prompt Studio.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                    }
                }
                .frame(height: 100)
                .environment(\.colorScheme, .dark)
                .padding(.bottom, 8)
                
                Group {
                    Spacer()
                    Text("Subscription Plans")
                        .font(Fonts.live(.headline, .bold))
                        .foregroundColor(.foreground)
                        .padding(.bottom, 8)
                    
                    if reducedPricing {
                        HStack(spacing: 8) {
                            ForEach(VaultManager.productsFor(VaultProducts.RenewableReduced.allCases).ordered) { product in
                                
                                optionView(product)
                            }
                        }
                        .padding(.bottom, 8)
                    } else {
                        HStack(spacing: 8) {
                            ForEach(VaultManager.productsFor(VaultProducts.Renewable.allCases).ordered) { product in
                                
                                optionView(product)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    AppBlurView(tintColor: Brand.Colors.yellow.opacity(0.45)) {
                        
                        HStack(spacing: 8) {
                            
                            Button(action: {
                                account
                                    .center
                                    .subscribe
                                    .send(AccountService.Subscribe.Meta(product: selectedOption))
                            }) {
                                Text("Subscribe")
                                    .font(Fonts.live(.headline, .bold))
                                    .foregroundColor(.foreground)
                                
                                Divider()
                                
                                Text(selectedOption?.metadata.displayPrice ?? "")
                                    .font(Fonts.live(.subheadline, .bold))
                                    .foregroundColor(.foreground) + //Text(selectedOption?.metadata.isRenewable == true ? "/mo" : "")
                                Text(selectedOption?.metadata.displaySubscriptionPeriod ?? "")
                                    .font(Fonts.live(.footnote, .regular))
                                    .foregroundColor(.foreground) +
                                Text(selectedOption?.metadata.displayPromo.isEmpty == true ? "" : " " + (selectedOption?.metadata.displayPromo ?? ""))
                                    .font(Fonts.live(.footnote, .regular))
                                    .foregroundColor(.foreground)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                    .environment(\.colorScheme, .dark)
                }
                
                Group {
                    Spacer()
                    
                    HStack {
                        Toggle("Have an OpenAI API Key? See cheaper options.", isOn: $reducedPricing)
                        
                        Spacer()
                    }
                    .onChange(of: reducedPricing) { newValue in
                        if newValue {
                            selectedOption = VaultManager.shared.productFor(VaultProducts.RenewableReduced.monthly)
                        } else {
                            selectedOption = VaultManager.shared.productFor(VaultProducts.Renewable.monthly)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    func optionView(_ product: VaultProduct) -> some View {
        AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
            HStack(spacing: 8) {
                Text(sanitizeDisplayName(product.metadata.displayName))
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
    
    func sanitizeDisplayName(_ value: String) -> String {
        return value.replacingOccurrences(of: " Subscription", with: "").replacingOccurrences(of: " Reduced", with: "")
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
            .padding(.bottom, 8)
            
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
                
                Spacer()
                
                AppBlurView(tintColor: Brand.Colors.red.opacity(0.45)) {
                    
                    HStack(spacing: 8) {
                        Button {
                            account.center.logout.send()
                        } label: {
                            
                            Text("Logout")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
