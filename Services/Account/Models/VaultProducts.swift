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
        case monthly = "monthlysubscriptionbasicneatia12"
        
        var kind: VaultProductKind {
            .renewable
        }
    }
    
    enum NonRenewable: String, VaultProductIterable {
        case month = "monthlyNonRenewablesubscriptionbasic12"
        case week = "weeklyNonRenewablesubscriptionbasic12"
        case day = "dailyNonRenewablesubscriptionbasic12"
        
        var kind: VaultProductKind {
            .nonRenewable
        }
    }
}
