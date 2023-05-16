import Granite
import SwiftUI
import SandKit

extension Response: View {
    public var view: some View {
        VStack(spacing: 0) {
            ZStack {
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
