//
//  GraniteTimerView.swift
//  Stoic
//
//  Created by PEXAVC on 1/3/23.
//

import Foundation
import GraniteUI
import SwiftUI
import Combine

public struct GraniteTimerView: View {
    public enum GraniteTimerType {
        case countup
        case countdown
    }
    
    public enum GraniteTimerStyle {
        case minimal
        case none
    }
    
    var empty: Bool = false
    var timerType: GraniteTimerType = .countup
    var timerStyle: GraniteTimerStyle = .none
    let initial: Date = .today
    var limit: Int = .max
    
    @State var timePassed = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public var body: some View {
        
        if empty {
            GraniteText("00:00:00",
                        .footnote,
                        .regular,
                        .leading)
        } else {
            Passthrough {
                switch timerStyle {
                case .minimal:
                    GraniteText("\(initial.asStringTimedWithTime((self.timePassed) * (timerType == .countup ? 1 : -1)))",
                                .footnote,
                                .regular,
                                .leading)
                default:
                    GraniteText("\(initial.asStringTimedWithTime((self.timePassed) * (timerType == .countup ? 1 : -1)))",
                                .subheadline,
                                .bold,
                                style: .init(gradient: [Brand.Colors.black.opacity(0.75),
                                                        Brand.Colors.black.opacity(0.36)]))
                }
            }
            .onReceive(timer) { _ in
                if timePassed <= limit {
                    timePassed += 1 //tate.type == .countup ? 1 : -1
                }
            }
        }
    }
}
