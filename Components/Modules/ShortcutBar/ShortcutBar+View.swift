import Granite
import SwiftUI
import SandKit
import Ink
import Cocoa
import WebKit

extension ShortcutBar: View {
    public var view: some View {
        VStack {
            Spacer()
                .allowsHitTesting(false)
            
            HStack {
                IconView(systemName: "arrow.clockwise",
                         bgColor: Color.background,
                         withBlur: true)
                .frame(width: 40, height: 32)
                .onTapGesture {
                    sand.center.reset.send()
                    environment.center.reset.send()
                }
                
                Spacer()
                
                if (sand.state.isResponding && sand.state.response.isNotEmpty) {
                    ProgressView()
                        .scaleEffect(.init(0.75, 0.75))
                } else if sand.state.response.isNotEmpty {
                    downloadButtonView
                }
            }
            .frame(height: WindowComponent.Kind.shortcutbar.defaultSize.height)
            .padding(.bottom, WindowComponent.Style.defaultContainerOuterPadding / 2)
        }
    }
}

extension ShortcutBar {
    var downloadButtonView: some View {
        AppBlurView(padding: .init(16)) {
            HStack(spacing: 8) {
                Text("Download PDF")
                    .lineLimit(1)
                    .font(Fonts.live(.subheadline, .bold))
                    .foregroundColor(.foreground)
                    .environment(\.colorScheme, .dark)
                
                IconView(systemName: "arrow.down.square")
                    .frame(width: 24,
                           height: WindowComponent.Style.defaultElementSize.height)
            }
        }
        .onTapGesture {
            guard sand.state.response.isNotEmpty else { return }
            let markdown: String = sand.state.response
            let parser = MarkdownParser()
            let result = parser.parse(markdown)
            
            let panel = NSSavePanel()
            panel.nameFieldLabel = "Save generation as:"
            panel.nameFieldStringValue = "neatia-\(Date().asStringWithTime).pdf"
            panel.canCreateDirectories = true
            panel.begin { response in
                if response == NSApplication.ModalResponse.OK,
                   let fileURL = panel.url {
                    createPDF(htmlString: result.html, url: fileURL)
                }
            }
            
        }
    }
    
    public func createPDF(htmlString: String, url: URL) {
        let webView = WebView()
        webView.mainFrame.loadHTMLString(htmlString, baseURL: nil)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            let printOpts: [NSPrintInfo.AttributeKey : Any] = [NSPrintInfo.AttributeKey.jobDisposition : NSPrintInfo.JobDisposition.save, NSPrintInfo.AttributeKey.jobSavingURL : url]
            let printInfo: NSPrintInfo = NSPrintInfo(dictionary: printOpts)
            printInfo.paperSize = NSMakeSize(595.22, 841.85)
            printInfo.topMargin = 10.0
            printInfo.leftMargin = 10.0
            printInfo.rightMargin = 10.0
            printInfo.bottomMargin = 10.0
            let printOp: NSPrintOperation = NSPrintOperation(view: webView.mainFrame.frameView.documentView, printInfo: printInfo)
            printOp.showsPrintPanel = false
            printOp.showsProgressPanel = false
            printOp.run()
        }
    }
}
