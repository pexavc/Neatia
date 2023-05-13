//
//  PEXApp.swift
//  Shared
//
//  Created by PEXAVC on 7/18/22.
//

import SwiftUI
import Combine
import Granite
import VaultKit

@main
struct PEXApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    
    let pubShowHideMount = NotificationCenter.default
        .publisher(for: NSNotification.Name("nyc.stoic.Neatia.ShowHideMount"))
    
    let pubDidFinishLaunching = NotificationCenter.default
        .publisher(for: NSNotification.Name("nyc.stoic.Neatia.DidFinishLaunching"))

    internal var cancellables = Set<AnyCancellable>()
    
    init() {
        pubShowHideMount.sink { _ in
            InteractionManager.shared.observeHotkey()
        }.store(in: &cancellables)
        
        VaultManager.shared.$isSubscribed
            .removeDuplicates()
            .sink { newValue in
                AccountManager.isSubscribed(newValue)
        }.store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            Home()
                .onReceive(pubDidFinishLaunching) { _ in
                    
                    environment.center.boot.send()
                    account.center.checkLogin.send()
                    
                    //TODO: fires too early
                    if AccountManager.isLoggedIn == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            MenuBarManager.shared.showPopOver()
                        }
                    }
                }
                .onChange(of: AccountManager.isLoggedIn) { newState in
                    print("[MAIN] isLoggedIn \(newState)")
                }
                .onChange(of: VaultManager.isSubscribed) { newState in
                    print("[MAIN] isSubscribed \(newState)")
                }
        }
//
//        Settings {
//            MacSettings {
//                MacSettingsItem(title: "Account",
//                               image: "gearshape",
//                               content: AccountConfigView())
//            }
//        }
    }
}

extension TimeZone {
    var formattedName: String {
        let start = localizedName(for: .generic, locale: .current) ?? "Unknow"
        return "\(start) - \(identifier)"
    }
}

//MARK: Hotkey Solution

