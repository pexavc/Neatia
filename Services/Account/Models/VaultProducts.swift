//
//  VaultProducts.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/12/23.
//

import Foundation
import VaultKit

struct VaultProducts {
    enum Renewable: String, VaultProductIterable {
        case yearly = "nyc.stoic.neatia.basic.subscription.yearly"
        case monthly = "nyc.stoic.neatia.basic.subscription.monthly"
        case weekly = "nyc.stoic.neatia.basic.subscription.weekly"
        
        var kind: VaultProductKind {
            .renewable
        }
    }
    
    enum RenewableReduced: String, VaultProductIterable {
        case yearly = "nyc.stoic.neatia.reduced.basic.subscription.yearly"
        case monthly = "nyc.stoic.neatia.reduced.basic.subscription.monthly"
        
        var kind: VaultProductKind {
            .renewable
        }
    }
}
