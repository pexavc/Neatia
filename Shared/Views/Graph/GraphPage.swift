//
//  RobinhoodPage.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Combine
import SwiftUI

public struct GraphStyle {
    let priceSize: Fonts.FontSize
    let dateSize: Fonts.FontSize
    let dateValuePadding: CGFloat
    let pricePadding: CGFloat
    let widthOfPriceViewIndicators: CGFloat
    let widthOfPriceView: CGFloat
    
    public static var basic: GraphStyle {
        .init(priceSize: .title2, dateSize: .headline, dateValuePadding: Brand.Padding.large, pricePadding: Brand.Padding.small, widthOfPriceViewIndicators: 183, widthOfPriceView: 220)
    }
}

public enum GraphType {
    case indicator(Color)
    case price(GraphStyle)
    case unassigned
    
    var symbol: String {
        switch self {
        case .indicator:
            return ""
        default:
            return "$"
        }
    }
    
    var style: GraphStyle {
        switch self {
        case .price(let style):
            return style
        default:
            return .basic
        }
    }
    
    var titleTextSpacing: CGFloat {
        switch self {
        case .indicator:
            return 0.0
        default:
            return 20.0
        }
    }
    
    var showStockHeader: Bool {
        switch self {
        case .indicator:
            return false
        default:
            return true
        }
    }
}

class SomePlotData: ObservableObject {
    typealias PlotData = GraphPageViewModel.PlotData
    @Published var plotData: PlotData?
    @Published var predictionPlotData: PlotData = []
    @Published var trueDays: Int?
    @Published var graphType: GraphType = .unassigned
    @Published var timeDisplayMode: TimeDisplayOption = .daily
    var segments: [Int] = []
    
    public init(_ data: PlotData,
                predictionPlotData: PlotData = [],
                segments: [Int] = [],
                interval: TimeDisplayOption,
                graphType: GraphType = .unassigned) {
        self.plotData = data
        self.predictionPlotData = predictionPlotData
        self.timeDisplayMode = interval
        self.graphType = graphType
        self.segments = segments
    }
    
    public init() {
        
    }
}
struct GraphPage: View {
    typealias PlotData = GraphPageViewModel.PlotData
    
    var timeDisplayMode: TimeDisplayOption {
        someModel.timeDisplayMode
    }
    @State var isLaserModeOn = false
    @State var currentIndex: Int? = nil
//    @ObservedObject var viewModel = RobinhoodPageViewModel(symbol: symbol)
    @ObservedObject var someModel = SomePlotData()
    
    
    var currentPlotData: PlotData {
        someModel.plotData ?? []
//        switch timeDisplayMode {
//        case .hourly:
//            return viewModel.intradayPlotData
//        case .daily:
//            return viewModel.dailyPlotData
//        case .weekly:
//            return viewModel.weeklyPlotData
//        case .monthly:
//            return viewModel.monthlyPlotData
//        }
    }
    
    var currentPredictionPlotData: PlotData {
        someModel.predictionPlotData
//        switch timeDisplayMode {
//        case .hourly:
//            return viewModel.intradayPlotData
//        case .daily:
//            return viewModel.dailyPlotData
//        case .weekly:
//            return viewModel.weeklyPlotData
//        case .monthly:
//            return viewModel.monthlyPlotData
//        }
    }
    
    var plotDataSegments: [Int]? {
        someModel.segments.isEmpty ? currentPlotData.enumerated().map { $0.offset } : someModel.segments
        
// OLD method, but the plot Data now comes in sorted as expected
//        switch timeDisplayMode {
//        case .hourly:
//            return GraphPageViewModel.segmentByHours(values: currentPlotData)
//        case .daily:
//            return GraphPageViewModel.segmentByDays(values: currentPlotData)
//        case .monthly:
//            return GraphPageViewModel.segmentByMonths(values: currentPlotData)
//        case .weekly:
//            return GraphPageViewModel.segmentByYears(values: currentPlotData)
//        }
    }
    
    var plotRelativeWidth: CGFloat {
        switch timeDisplayMode {
        case .hourly:
            return 0.98//0.7 // simulate today's data
        default:
            return 1.0
        }
    }
    
    var showGlowingIndicator: Bool {
        switch timeDisplayMode {
        case .hourly:
            return true // simulate today's data
        default:
            return false
        }
    }
    
    // MARK: Body
    func readyPageContent(plotData: PlotData, predictionPlotData: PlotData) -> some View {
        return VStack {
            
            if someModel.graphType.showStockHeader {
                VStack(alignment: .leading, spacing: 0) {
                    stockHeaderAndPrice(plotData: plotData+predictionPlotData)
                }.padding(.top, Brand.Padding.small)
                .padding(.leading, someModel.graphType.style.pricePadding)
            }
            
            VStack {
                plotBody(plotData: plotData, predictionPlotData: predictionPlotData)
            }
            
        }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .topLeading)
    }
    
    var body: some View {
        VStack {
            if currentPlotData.isEmpty {
                GraniteText(""/*"loading..."*/, .subheadline, .regular)
            } else {
                readyPageContent(plotData: currentPlotData, predictionPlotData: currentPredictionPlotData)
            }
        }
        .accentColor(graphThemeColor)
        .environment(\.graphLinePlotConfig, GraphLinePlotConfig.default.custom(f: { (c) in
            c.useLaserLightLinePlotStyle = isLaserModeOn
        }))
    }
}

// MARK:- Components
extension GraphPage {
    func plotBody(plotData: PlotData, predictionPlotData: PlotData) -> some View {
        let combined = (plotData + predictionPlotData)
        let values = combined.map { $0.price }
        let dates = combined.map { $0.time }
        let nonPredictionDates = plotData.map { $0.time }
        let predictionDates = predictionPlotData.map { $0.time }
        let currentIndex = self.currentIndex ?? (values.count - 1)
        // For value stick
        let dateString: String
        
        switch timeDisplayMode {
        case .hourly:
            dateString = combined[currentIndex].time.asStringWithTime
        default:
            dateString = combined[currentIndex].time.asString
        }
        
//        let themeColor = values.last! >= values.first! ? rhThemeColor : rhRedThemeColor
        
        return GraphInteractiveLinePlot(
            nonPredictionCount: someModel.trueDays ?? currentPlotData.count,
            graphType: someModel.graphType,
            values: values,
            dates: dates,
            nonPredictionDates: nonPredictionDates,
            predictionDates: predictionDates,
            occupyingRelativeWidth: plotRelativeWidth,
            showGlowingIndicator: showGlowingIndicator,
            lineSegmentStartingIndices: plotDataSegments,
            segmentSearchStrategy: .binarySearch,
            didSelectValueAtIndex: { ind in
                self.currentIndex = ind
        },
            didSelectSegmentAtIndex: { segmentIndex in
                if segmentIndex != nil {
                    Haptic.onChangeLineSegment()
                }
        },
            valueStickLabel: { value in
                VStack(spacing: Brand.Padding.xSmall) {
                    if !someModel.graphType.showStockHeader {
                        buildMovingPriceView(input: value,
                                             fixedWidth: someModel.graphType.style.widthOfPriceViewIndicators,
                                             alignment: .center)
                            .font(Fonts.live(.title3, .bold))
                    }
                    Text("\(dateString)")
                        .foregroundColor(Brand.Colors.marble)
                        .font(Fonts.live(someModel.graphType.style.dateSize, .bold))
                }.padding(.top, someModel.graphType.style.dateValuePadding)
        })
            //.frame(height: 280)
//            .foregroundColor(themeColor)
    }
    
    func stockHeaderAndPrice(plotData: PlotData) -> some View {
        return HStack {
//            VStack(alignment: .leading, spacing: 0) {
////                Text("\(Self.symbol)")
////                    .rhFont(style: .title1, weight: .heavy)
//                buildMovingPriceLabel(plotData: plotData)
//            }.frame(minWidth: 0, maxWidth: .infinity)
            buildMovingPriceLabel(plotData: plotData)
            Spacer().frame(minWidth: 0, maxWidth: .infinity)
        }
        .padding(.horizontal, 0.0)
    }
    
    func buildMovingPriceLabel(plotData: PlotData) -> some View {
        let currentIndex = self.currentIndex ?? (plotData.count - 1)
        return HStack(spacing: 2) {
            
            Text(someModel.graphType.symbol)
                .background(with: Brand.Colors.black.opacity(0.75))
                    .frame(width: someModel.graphType.titleTextSpacing)
            buildMovingPriceView(input: plotData[currentIndex].price, fixedWidth: someModel.graphType.style.widthOfPriceView)
        }.font(Fonts.live(someModel.graphType.style.priceSize, .bold))
    }
    
    func buildMovingPriceView(input: CGFloat,
                              fixedWidth: CGFloat,
                              alignment: Alignment = .leading) -> some View {
        return MovingNumbersView(
            number: Double(input),
            numberOfDecimalPlaces: 2,
            verticalDigitSpacing: 0,
            animationDuration: 0.3,
            fixedWidth: fixedWidth,
            alignment: alignment) { (digit) in
                Text(digit)
        }
        .mask(LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: .clear, location: 0),
                Gradient.Stop(color: .black, location: 0.2),
                Gradient.Stop(color: .black, location: 0.8),
                Gradient.Stop(color: .clear, location: 1.0)]),
            startPoint: .top,
                endPoint: .bottom))
    }
}

extension View {
  func background(with color: Color) -> some View {
    background(GeometryReader { geometry in
      Rectangle().path(in: geometry.frame(in: .local)).foregroundColor(color)
    })
  }
}

struct RobinhoodPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GraphPage()
                .environment(\.colorScheme, .dark)
        }.previewLayout(.device)//.fixed(width: 320, height: 480))
    }
}
