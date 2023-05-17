import Granite
import SwiftUI
import SandKit

extension Response: View {
    public var view: some View {
        VStack(spacing: 0) {
            ZStack {
                if sand.state.isResponding {
                    LoadingView()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(x: -WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
                }
                
                MarkdownView(markdown: sand.state.response,
                             padding: .init(Fonts.Details.from(.defaultResponseSize).actualHeight,
                                            0,
                                            Fonts.Details.from(.defaultResponseSize).actualHeight,
                                            0)) { lineCount in
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
                .animation(
                    .default,
                    value: sand.state.response.count
                )
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
                
                if sand.state.isResponding && sand.state.response.isEmpty {
                    ProgressView()
                }
            }
        }
    }
}

struct LoadingView: View {
    
    @State var timer: Timer?
    
    @State var containerWidth: CGFloat = 0
    @State var percent: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            
            Brand.Colors.purple
                .opacity(0.35)
                .frame(width: containerWidth * percent)
                .frame(maxHeight: .infinity)
                .animation(.default, value: percent)
                .onAppear {
                    self.containerWidth = proxy.width
                    
                    timer = Timer
                        .scheduledTimer(withTimeInterval: 2.randomBetween(3),
                                        repeats: true) { _ in
                            
                            percent += 0.1
                        }
                }
        }
    }
}
