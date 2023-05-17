//
//  PEXApp.Delegate.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/6/23.
//

import Foundation
import SwiftUI
import Firebase

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var menuBarManager: MenuBarManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.delegate = self
        
        FirebaseApp.configure()
        
        //Window close
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        menuBarManager = MenuBarManager.shared
        menuBarManager?.setup()
        MenuBarManager.shared.menu.delegate = self
        menuBarManager?.statusItem?.button?.action = #selector(self.statusBarButtonClicked(sender:))
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("nyc.stoic.Neatia.DidFinishLaunching"), object: nil)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication,
                                       hasVisibleWindows flag: Bool) -> Bool {
        return false
    }
    
    func addMenuItems() {
        let menu = MenuBarManager.shared.menu
        menu.removeAllItems()
        
        menu.addItem(withTitle: "Settings",
                     action: #selector(ShowSettings),
                     keyEquivalent: "")
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "")
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        addMenuItems()
        MenuBarManager.shared.popover.performClose(self)
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        MenuBarManager.shared.statusBarClicked(event)
    }
    
    @objc func ShowHideMount() {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("nyc.stoic.Neatia.ShowHideMount"), object: nil)
        MenuBarManager.shared.mountIsClosed.toggle()
    }
    
    @objc func ShowSettings() {
        MenuBarManager.shared.showPopOver()
    }
    
    @objc func copyToClipboard(_ sender: NSMenuItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(sender.title,
                                       forType: .string)
    }
    
    @objc func quit() {
        NSApp.terminate(self)
    }
}
