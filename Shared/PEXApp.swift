//
//  PEXApp.swift
//  Shared
//
//  Created by PEXAVC on 7/18/22.
//

import SwiftUI
import Combine
import Granite

@main
struct PEXApp: App {
    var isDebug: Bool = true
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    
    let pubShowHideMount = NotificationCenter.default
        .publisher(for: NSNotification.Name("ShowHideMount"))
    
    let pubLogout = NotificationCenter.default
        .publisher(for: NSNotification.Name("Logout"))
    
    let pubDidFinishLaunching = NotificationCenter.default
        .publisher(for: NSNotification.Name("DidFinishLaunching"))
    
//    let pubActivate = NotificationCenter.default
//        .publisher(for: NSNotification.Name("Activate"))
    
    internal var cancellables = Set<AnyCancellable>()
    init() {
//        pubActivate.sink { _ in
//
////            WindowManager.Manager.shared.check()
//        }.store(in: &cancellables)
        
        pubShowHideMount.sink { _ in
            InteractionManager.shared.observeHotkey()
        }.store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            Home()
                .onReceive(pubDidFinishLaunching) { _ in
                    
                    environment.center.boot.send()
                    account.center.checkLogin.send()
                    
                    //TODO: fires too early
                    if account.center.state.isLoggedIn == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            MenuBarManager.shared.showPopOver()
                        }
                    }
                }
        }
        
        Settings {
            MacSettings {
                MacSettingsItem(title: "Account",
                               image: "gearshape",
                               content: AccountConfigView())
            }
        }
    }
}

extension TimeZone {
    var formattedName: String {
        let start = localizedName(for: .generic, locale: .current) ?? "Unknow"
        return "\(start) - \(identifier)"
    }
}

//MARK: Hotkey Solution

