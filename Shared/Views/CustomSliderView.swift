//
//  CustomSlider.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/14/23.
//

import Foundation
import SwiftUI

struct CustomSliderView: View {
    @Binding var value: Double
    
    var color: Color
    
    @State var lastCoordinateValue: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { gr in
            let cursorSize = gr.size.height * 0.8
            let radius = gr.size.height * 0.5
            let minValue = gr.size.width * 0.015
            let maxValue = (gr.size.width * 0.98) - cursorSize
            
            let width = maxValue - minValue
            
            ZStack {
                RoundedRectangle(cornerRadius: radius)
                    .foregroundColor(color)
                
                HStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: cursorSize, height: cursorSize)
                        .offset(x: self.value * width)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateValue = self.value * width
                                    }
                                    
                                    if v.translation.width > 0 {
                                        self.value = min(maxValue, self.lastCoordinateValue + v.translation.width) / width
                                    } else {
                                        self.value = max(minValue, self.lastCoordinateValue + v.translation.width) / width
                                    }
                                }
                        )
                    
                    Spacer()
                }
            }
        }
    }
}
