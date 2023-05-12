//
//  PaneKit.Window.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/8/23.
//

import Foundation
import SwiftUI

extension PaneKit {
    class Window: NSObject, Identifiable {
        @Published var isPrepared: Bool = false
        
        private var main: AppWindow? = nil
        
        private(set) var lastUpdate: Date = .init()
        
        let size: CGSize
        let maxSize: CGSize
        private(set) var titleBarHeight: CGFloat = 0
        
        private var isVisible: Bool = false
        
        init(size: CGSize = .init(800, 48), maxSize: CGSize = .init(800, 750)) {
            self.size = size
            self.maxSize = maxSize
            super.init()
        }
        
        func build() {
            DispatchQueue.main.async { [weak self] in
                self?.main = AppWindow(self?.size ?? .zero)
                self?.titleBarHeight = self?.main?.titlebarHeight ?? 0
                self?.isPrepared = true
                self?.lastUpdate = .init()
                print("[PaneKit.Window] Built \(self?.lastUpdate)")
            }
        }
        
        func setHost<Content: View>(_ controller: NSHostingController<Content>) {
            self.main?.contentViewController = controller
        }
        
        func setSize(_ size: CGSize) {
            let sizeAdjusted: CGSize = .init(min(maxSize.width, size.width), min(maxSize.height, size.height + titleBarHeight))
            DispatchQueue.main.async { [weak self] in
                self?.main?.setSize(sizeAdjusted, defaultSize: self?.size ?? .zero)
            }
        }
        
        func toggle() {
            if isVisible {
                main?.close()
            } else {
                main?.makeKeyAndOrderFront(nil)
            }
            isVisible.toggle()
        }
    }
}

//MARK: AppWindow class

class AppWindow: NSWindow {
    
    private var lastPoint: CGPoint? = nil
    
    init(_ size: CGSize) {
        
        let origin = AppWindow.originPoint(size, newSize: .zero)
        
        super.init(contentRect: .init(origin: origin, size: size),
                   styleMask: [.fullSizeContentView, .titled, .closable],
                   backing: .buffered,
                   defer: false)
        
        self.lastPoint = origin
        
        isReleasedWhenClosed = false
        hasShadow = true
        isOpaque = false
        
        level = .floating
        backgroundColor = .clear
        
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
    }
    
    static func originPoint(_ size: CGSize, newSize: CGSize, titleBarHeight: CGFloat = 28, currentMidPoint: CGPoint? = nil) -> CGPoint {
        guard let main = NSScreen.main else {
            return .zero
        }
        
        let startingContainer: CGSize = .init(size.width, size.height + titleBarHeight)
        let newContainer: CGSize = .init(newSize.width, newSize.height + titleBarHeight)
        
        let visibleFrame = main.visibleFrame
        let startWindowX = (currentMidPoint?.x) ?? ((visibleFrame.midX) - (startingContainer.width / 2))
        let startWindowY = (currentMidPoint?.y) ?? ((visibleFrame.midY) - (startingContainer.height / 2))
//        print("[AppWindow] originPoint: \(visibleFrame)")
        var startPoint: CGPoint = .init(startWindowX, startWindowY)
        
        if newSize != .zero {
            let diff = newContainer.height - startingContainer.height
            
            startPoint.y -= diff
        } else {
            startPoint.y -= visibleFrame.origin.y
        }
        
        if currentMidPoint == nil {
            startPoint.y += (visibleFrame.height / 3) / 2
        }
        
        return startPoint
    }
    
    func newPoint(newSize: CGSize,
                  titleBarHeight: CGFloat = 28,
                  currentMidPoint: CGPoint? = nil) -> CGPoint {
        
        let startingContainer: CGSize = frame.size
        let newContainer: CGSize = .init(newSize.width, newSize.height)
        
        var startPoint: CGPoint = lastPoint ?? .zero
        
        if newSize != .zero {
            let diff = newContainer.height - startingContainer.height
            
            startPoint.y -= (diff)
        }
        
        lastPoint = startPoint
        
        return startPoint
    }
    
    func setSize(_ newSize: CGSize, defaultSize: CGSize) {
        lastPoint = frame.origin
        let origin: CGPoint = newPoint(newSize: newSize, titleBarHeight: self.titlebarHeight, currentMidPoint: lastPoint)
        print("[AppWindow] \(lastPoint ?? .zero) new: \(origin)")
        self.setFrame(.init(origin, newSize), display: true)
    }
}

extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentLayoutRect.height
    }
}
