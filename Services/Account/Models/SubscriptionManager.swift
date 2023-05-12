//
//  SubscriptionManager.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/8/23.
//

import Foundation
import SwiftyStoreKit

class SubscriptionManager {
    static var shared: SubscriptionManager = .init()
    
    enum Product: String, CaseIterable {
        case monthly = "sina.monthly.subscription.basic1299"
    }
    
    func retrieveProductInfo() {
        SwiftyStoreKit.retrieveProductsInfo(Set(Product.allCases.map { $0.rawValue })) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
    }
    
    func purchase(_ productId: String, _ completion: (@escaping (PurchaseDetails?) -> Void)) {
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                completion(purchase)
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
                completion(nil)
            case .deferred(purchase: let purchase):
                print("[AccountService] [SubscriptionManager] deferred purchase")
                completion(nil)
            }
        }
    }
}
