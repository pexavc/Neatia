//
//  Interaction.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/6/23.
//

import Granite
import Foundation
import SwiftUI
import Carbon

enum Interaction: GraniteModel {
    case enable
    case disable
}

class InteractionManager {
    static var shared: InteractionManager = .init()
    
    var hotkeyObserver: (() -> Void)?
    var menubarShowHideMount: (() -> Void)?
    var hotKeyRef: EventHotKeyRef?
    var mountIsClosed: Bool = false
    
    init() {
        
    }
    
    func setHotkeyObserver<S: EventExecutable>(_ reducer: S) {
        hotkeyObserver = {
            reducer.send()
        }
    }
    
    func observeHotkey() {
        hotkeyObserver?()
    }
}

extension InteractionManager {
    func registerHotkey(_ key: HotkeyOptions = .s) {
        if self.hotKeyRef != nil {
            let status = UnregisterEventHotKey(hotKeyRef)
            NSLog("[InteractionManager] Un registered hotkey successfully")
        }
        
        var hotKeyRef: EventHotKeyRef?
        let modifierFlags: UInt32 =
        getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags.option)
        
        let keyCode = key.asANSI
        var gMyHotKeyID = EventHotKeyID()
        
        gMyHotKeyID.id = UInt32(keyCode)
        
        // Not sure what "swat" vs "htk1" do.
        gMyHotKeyID.signature = OSType("swat".fourCharCodeValue)
        // gMyHotKeyID.signature = OSType("htk1".fourCharCodeValue)
        
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyReleased)
        // Install handler.
        
        NSLog("[InteractionManager] Registering")
        InstallEventHandler(GetApplicationEventTarget(), {
            (nextHanlder, theEvent, userData) -> OSStatus in
            // var hkCom = EventHotKeyID()
            
            // GetEventParameter(theEvent,
            //                   EventParamName(kEventParamDirectObject),
            //                   EventParamType(typeEventHotKeyID),
            //                   nil,
            //                   MemoryLayout<EventHotKeyID>.size,
            //                   nil,
            //                   &hkCom)
            
//            NSLog("Option + S Released!")
            
//            let nc = NotificationCenter.default
//            nc.post(name: Notification.Name("Activate"), object: nil)
            
            InteractionManager.shared.observeHotkey()
            
            
            return noErr
            /// Check that hkCom in indeed your hotkey ID and handle it.
        }, 1, &eventType, nil, nil)
        
        // Register hotkey.
        let status = RegisterEventHotKey(UInt32(keyCode),
                                         modifierFlags,
                                         gMyHotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &hotKeyRef)
        
        if status == noErr {
            self.hotKeyRef = hotKeyRef
            NSLog("[InteractionManager] Registered hotkey successfully")
        } else {
            NSLog("[InteractionManager] error \(status)")
        }
    }
    
    func getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags) -> UInt32 {
        let flags = cocoaFlags.rawValue
        var newFlags: Int = 0
        
        if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
            newFlags |= controlKey
        }
        
        if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
            newFlags |= cmdKey
        }
        
        if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
            newFlags |= shiftKey;
        }
        
        if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
            newFlags |= optionKey
        }
        
        if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
            newFlags |= alphaLock
        }
        
        return UInt32(newFlags);
    }
    
    enum HotkeyOptions: String, CaseIterable, Equatable, Codable {
        case a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
        
        var asANSI: Int {
            switch self {
            case .a:
                return kVK_ANSI_A
            case .b:
                return kVK_ANSI_B
            case .c:
                return kVK_ANSI_C
            case .d:
                return kVK_ANSI_D
            case .e:
                return kVK_ANSI_E
            case .f:
                return kVK_ANSI_F
            case .g:
                return kVK_ANSI_G
            case .h:
                return kVK_ANSI_H
            case .i:
                return kVK_ANSI_I
            case .j:
                return kVK_ANSI_J
            case .k:
                return kVK_ANSI_K
            case .l:
                return kVK_ANSI_L
            case .m:
                return kVK_ANSI_M
            case .n:
                return kVK_ANSI_N
            case .o:
                return kVK_ANSI_O
            case .p:
                return kVK_ANSI_P
            case .q:
                return kVK_ANSI_Q
            case .r:
                return kVK_ANSI_R
            case .s:
                return kVK_ANSI_S
            case .t:
                return kVK_ANSI_T
            case .u:
                return kVK_ANSI_U
            case .v:
                return kVK_ANSI_V
            case .w:
                return kVK_ANSI_W
            case .x:
                return kVK_ANSI_X
            case .y:
                return kVK_ANSI_Y
            case .z:
                return kVK_ANSI_Z
            }
        }
    }
}

extension String {
    /// This converts string to UInt as a fourCharCode
    public var fourCharCodeValue: Int {
        var result: Int = 0
        if let data = self.data(using: String.Encoding.macOSRoman) {
            data.withUnsafeBytes({ (rawBytes) in
                let bytes = rawBytes.bindMemory(to: UInt8.self)
                for i in 0 ..< data.count {
                    result = result << 8 + Int(bytes[i])
                }
            })
        }
        return result
    }
}
