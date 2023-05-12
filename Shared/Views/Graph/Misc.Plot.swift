//
//  Misc.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

private let rhFontName = "HelveticaNeue"
let graphThemeColor = Brand.Colors.green
let graphRedThemeColor = Brand.Colors.red

extension Calendar {
    func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay(for: date))!
    }
    
    func startOfWeekOfYear(for date: Date) -> Date {
        let components = self.dateComponents([.weekOfYear, .yearForWeekOfYear], from: startOfDay(for: date))
        return self.date(from: components)!
    }
    
    func startOfMonth(for date: Date) -> Date {
        let components = self.dateComponents([.month, .year], from: startOfDay(for: date))
        return self.date(from: components)!
    }
    
    func endOfMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfMonth(for: date))!
    }
    
    func startOfYear(for date: Date) -> Date {
        let components = self.dateComponents([.year], from: startOfDay(for: date))
        return self.date(from: components)!
    }
}

extension CGFloat {
    func round2Str() -> String {
        String(format: "%.2f", self)
    }
}
