import Granite
import SwiftUI
import SandKit

extension Response: View {
    public var view: some View {
        VStack(spacing: 0) {
            ZStack {
                if config.state.streamResponse == false && sand.state.isResponding {
                    LoadingView()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(x: -WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
                }
                
                MarkdownView(markdown: sand.state.response,
                             padding: .init(Fonts.Details.from(.defaultResponseSize).actualHeight,
                                            0,
                                            Fonts.Details.from(.defaultResponseSize).actualHeight,
                                            0),
                             isLazy: config.state.streamResponse) { lineCount in
                    guard lineCount > 0 && config.state.streamResponse else { return }
                    environment
                        .center
                        .responseWindowSize
                        .send(
                            EnvironmentService
                                .ResponseWindowSizeUpdated
                                .Meta(lineCount: lineCount))
                }
                .environment(\.font, Fonts.live(.defaultResponseSize, .regular))
                .padding(.horizontal, 4)
//                .animation(
//                    .default,
//                    value: sand.state.response.count
//                )
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
                
                if sand.state.isResponding && sand.state.response.isEmpty {
                    ProgressView()
                }
                
                if sand.state.responseHelpers.isNotEmpty {
                    ResponseHelperView(helperInfo: sand.state.responseHelpers)
                }
            }
        }
    }
}

struct LoadingView: View {
    
    @State var timer: Timer?
    
    @State var percent: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            
            Brand.Colors.purple
                .opacity(0.25)
                .frame(width: proxy.width * percent)
                .frame(maxHeight: .infinity)
                .animation(.default, value: percent)
                .onAppear {
                    timer = Timer
                        .scheduledTimer(withTimeInterval: 3.randomBetween(4),
                                        repeats: true) { timer in
                            
                            percent += 0.05.randomBetween(0.1)
                            
                            if percent >= 1.0 {
                                timer.invalidate()
                            }
                        }
                }
        }
    }
}
