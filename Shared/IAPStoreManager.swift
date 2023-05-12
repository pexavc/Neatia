//
//  StoreManager.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/5/23.
//

import Foundation
enum AppProduct: String, CaseIterable {
    case monthly = "sina.monthly.subscription.basic1299"
}

typealias SinaStoreManager = StoreManager<AppProduct>

class IAPStoreManager {
    static var shared: IAPStoreManager = .init()
    let store = SinaStoreManager()
}
