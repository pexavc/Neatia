//
//  PromptStudioEditorView.ExportImport.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/18/23.
//

import Foundation
import MarqueKit
import SwiftUI

extension PromptStudioEditorView {
    var exportButtonView: some View {
        AppBlurView(padding: .init(16),
                    tintColor: Brand.Colors.black.opacity(0.3)) {
            Button {
                
                if let dict = try? JSONEncoder().encode(asCustomPrompt),
                   let stringV = String(data: dict, encoding: .utf8) {
                    
                    guard let pietaURL = Bundle.main.url(forResource: "pieta", withExtension: ".png") else { return }
                    guard let pieta = NSImage(contentsOf: pietaURL) else {
                        return
                    }
                    
                    guard let data = pieta.png else { return }
                    
                    let nsData = NSData(data: data)
                    
                    let bytes = getArrayOfBytesFromImage(imageData: nsData)
                    
                    //2. Encrypt json data (UInt32 array)
                    let imageData = MarqueKit().encodeBytes(stringV, withObject: bytes).data
                    
                    //3. Serialize into data object again
                    guard let writableData = try? JSONSerialization.data(withJSONObject: imageData, options: []) else {
                        return
                    }
                    
                    print("[PromptStudioEditorView] encoded: \(imageData.count)")
                    
                    //4. Save
                    let panel = NSSavePanel()
                    panel.nameFieldLabel = "Save prompt as:"
                    panel.nameFieldStringValue = "\(self.promptCommand).neatia"
                    panel.canCreateDirectories = true
                    panel.allowedContentTypes = [.init(exportedAs: "nyc.stoic.Neatia-neatia-custom-prompt-v1.0")]
                    panel.begin { response in
                        if response == NSApplication.ModalResponse.OK,
                           let fileURL = panel.url {
                            
                            try? writableData.write(to: fileURL)
                        }
                    }
                }
                
            } label : {
                HStack(spacing: 8) {
                    Text("Export")
                        .lineLimit(1)
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "arrow.up.square")
                        .font(Fonts.live(.title3, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                        .padding(.bottom, 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var importButtonView: some View {
        AppBlurView(padding: .init(16),
                    tintColor: Brand.Colors.black.opacity(0.3)) {
            Button {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canCreateDirectories = false
                panel.allowedContentTypes = [.init(exportedAs: "nyc.stoic.Neatia-neatia-custom-prompt-v1.0"), .init(importedAs: "nyc.stoic.Neatia-neatia-custom-prompt-v1.0")]
                if panel.runModal() == .OK {
                    if let url = panel.url {
                        
                        //1. Retrieve as data
                        if let data = try? Data(contentsOf: url) {
                            //2. Convert into encrypted data
                            guard let array = try? JSONSerialization.jsonObject(with: data, options: []) as? [UInt32] else {
                                return
                            }
                            
                            //3. Decrypt data
                            if let decoded = ConfigService.decode(array) {
                                if let data = decoded.data(using: .utf8) {
                                    
                                    do {
                                        //4. Deserialize into json dictionary representation
                                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                                        
                                        //5. Convert to target object
                                        if let decodedData = json,
                                           let prompt = try? BasicDictionaryDecoder().decode(CustomPrompt.self, from: decodedData) {
                                            
                                            
                                            update(prompt)
                                            print("[PS] 4 \(service.commands.contains(prompt.command.value.lowercased()))")
                                        }
                                    } catch let error {
                                        print("{TEST} \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                }
                
            } label : {
                HStack(spacing: 8) {
                    Text("Import")
                        .lineLimit(1)
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "arrow.down.square")
                        .font(Fonts.live(.title3, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                        .padding(.bottom, 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

fileprivate func getArrayOfBytesFromImage(imageData:NSData) -> Array<UInt32>
{
    
    // the number of elements:
    let count = imageData.length / MemoryLayout<UInt32>.size
    
    // create array of appropriate length:
    var bytes = [UInt32](repeating: 0, count: count)
    
    // copy bytes into array
    imageData.getBytes(&bytes, length:count * MemoryLayout<UInt32>.size)
    
    var byteArray:Array = Array<UInt32>()
    
    for i in 0 ..< count {
        byteArray.append(bytes[i])
    }
    
    return byteArray
}
