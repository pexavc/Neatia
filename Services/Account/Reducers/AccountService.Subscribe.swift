//
//  Account.Subscribe.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/5/23.
//

import Granite
import AuthenticationServices
import FirebaseAuth
import SwiftyStoreKit

extension AccountService {
    struct Subscribe: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Event var response: SubscribeResponse.Reducer
        
        func reduce(state: inout Center.State) {
//            print("{TEST} yo")
//            if IAPStoreManager.shared.store.openForBusiness {
//
//                let info = IAPStoreManager.shared.store.productInfo(for: .monthly)
//
//                print("{TEST} subscribe \(info?.displayPrice)")
//            } else {
//
//                IAPStoreManager.shared.store.restorePurchases()
//            }
            SubscriptionManager.shared.purchase(SubscriptionManager.Product.monthly.rawValue) { purchase in
                response.send(SubscribeResponse.Meta(details: purchase))
            }
        
        }
    }
    
    struct SubscribeResponse: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            let details: PurchaseDetails?
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            print("[AcountService] purchase succeeded? \(meta.details?.needsFinishTransaction) // \(meta.details == nil)")
        }
    }
    
    struct CheckSubscriptionStatus: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Relay var environment: EnvironmentService
        
        @Event var complete: CheckSubscriptionSuceeded.Reducer
        
        func reduce(state: inout Center.State) {
            
            
            let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: "73ceae3a85364087b79fd02d8e0371cd")
            
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    let productId = "com.musevisions.SwiftyStoreKit.Subscription"
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, // or .nonRenewing (see below)
                        productId: productId,
                        inReceipt: receipt)
                    
                    
                    environment
                        .center
                        .interact
                        .send(
                            EnvironmentService
                                .Interact
                                .Meta(interaction: .enable))
                    
                    complete.send()
                        
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    case .expired(let expiryDate, let items):
                        print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    case .notPurchased:
                        print("The user has never purchased \(productId)")
                    }

                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            }
        }
    }
    
    struct CheckSubscriptionSuceeded: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Relay var environment: EnvironmentService
        
        func reduce(state: inout Center.State) {
            state.isSubscribed = true
            
            environment.center.hotkeyDetected.send()
        }
    }
}
