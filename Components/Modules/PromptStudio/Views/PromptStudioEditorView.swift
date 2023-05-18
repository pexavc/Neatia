//
//  PromptStudioEditorView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/13/23.
//

import Foundation
import Granite
import SwiftUI
import GPT3_Tokenizer
import SandKit
import MarqueKit

struct PromptStudioEditorView: View {
    @GraniteAction<Void> var closeCreatePrompt
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
    @Relay var service: PromptService
    
    var isEditing: Bool = false
    
    var titleText: String {
        if isEditing {
            return "Edit prompt"
        } else {
            return "Create new prompt"
        }
    }
    
    var modeText: String {
        if promptCreativity > 0.7 {
            return "Very Creative"
        } else if promptCreativity > 0.5 {
            return "Creative"
        } else if promptCreativity > 0.3 {
            return "Strict"
        } else {
            return "Very Strict"
        }
    }
    
    @State var promptCommand: String
    @State var promptBody: String
    @State var promptDescription: String
    @State var promptRole: String
    @State var promptColor: String = ColorPicker.toHex(h: 0.5, s: 0.5, b: 0.5)
    @State var promptIcon: String
    @State var promptCreativity: Double = 0.7
    @State var promptCustomConfig: PromptConfig? = nil
    
    @State var showError: Bool = false
    
    let tokenizer: GPT3Tokenizer = .init()
    
    var asCustomPrompt: CustomPrompt {
        .init(.init(promptCommand),
              prompt: promptBody,
              iconName: promptIcon,
              baseColorHex: promptColor,
              description: promptDescription,
              creativity: promptCreativity,
              role: promptRole,
              tokenCount: promptTokenCount,
              customConfig: promptCustomConfig)
    }
    
    init() {
        promptCommand = ""
        promptBody = ""
        promptDescription = ""
        promptColor = ColorPicker.toHex(h: 0.5, s: 0.5, b: 0.5)
        promptIcon = "questionmark"
        promptRole = "Assistant"
    }
    
    init(_ prompt: CustomPrompt) {
        self.isEditing = true
        
        promptCommand = prompt.command.command
        promptBody = prompt.prompt
        promptDescription = prompt.description
        promptColor = prompt.baseColorHex
        promptIcon = prompt.iconName
        promptRole = prompt.role
        promptCreativity = promptCreativity
    }
    
    var promptTokenCount: Int {
        //SandGPT.shared.gpt3Tokenizer.encoder.enconde(text: promptBody).count
        tokenizer.encoder.enconde(text: promptBody).count
    }
    
    var isValid: Bool {
        promptCommand.isNotEmpty &&
        promptBody.isNotEmpty &&
        promptDescription.isNotEmpty &&
        promptTokenCount <= PromptService.customPromptMaxTokenCount &&
        (
            service.commands.contains(promptCommand) == false && isEditing == false || isEditing
        )
    }
    
    var errorMessage: String {
        if promptTokenCount > PromptService.customPromptMaxTokenCount {
            return "Reduce the token count of your instructions to \(PromptService.customPromptMaxTokenCount) tokens or less."
        }
        
        if service.commands.contains(promptCommand) && isEditing == false {
            return "Command already exists"
        }
        
        var string: String = "You still need to add "
        
        var issues: [String] = []
        if promptCommand.isEmpty {
            issues.append("a command")
        }
        
        if promptDescription.isEmpty {
            issues.append("a description")
        }
        
        if promptBody.isEmpty {
            if issues.count > 0 {
                issues.append("and instructions")
            } else {
                issues.append("instructions")
            }
        } else if issues.count > 1 {
            issues.insert("and", at: issues.count - 1)
        }
        
        string += issues.joined(separator: issues.count > 2 ? ", " : " ")
        
        return string
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(titleText)
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                    
                    if isEditing {
                        exportButtonView
                            .padding(.top, 4)
                    } else {
                        importButtonView
                            .padding(.top, 4)
                    }
                    
                    AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button(action: {
                            closeCreatePrompt.perform()
                        }) {
                            Text("Back")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                    .padding(.top, 4)
                }
                .padding(.bottom, 8)
                
                //includes tuneView
                commandView
                    .padding(.bottom, 4)
                
                HStack() {
                    
                    shortDescriptionView
                    
                    roleView
                }
                .padding(.bottom, 4)
                
                Text("Instructions")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                instructionsView
                
                Spacer()
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    if isEditing {
                        AppBlurView(tintColor: Brand.Colors.red.opacity(0.3)) {
                            Button(action: {
                                service
                                    .center
                                    .delete
                                    .send(PromptService
                                        .Delete
                                        .Meta(prompt: asCustomPrompt))
                                
                                closeCreatePrompt.perform()
                            }) {
                                Text("Delete")
                                    .font(Fonts.live(.headline, .bold))
                                    .foregroundColor(.foreground)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        .environment(\.colorScheme, .dark)
                    }
                    
                    AppBlurView(tintColor: Brand.Colors.purple.opacity(0.45)) {
                        Button(action: {
                            if isValid {
                                if isEditing {
                                    
                                    service
                                        .center
                                        .modify
                                        .send(PromptService
                                            .Modify
                                            .Meta(prompt: asCustomPrompt))
                                } else {
                                    
                                    service
                                        .center
                                        .create
                                        .send(PromptService
                                            .Create
                                            .Meta(prompt: asCustomPrompt))
                                }
                                
                                closeCreatePrompt.perform()
                            } else {
                                showError = true
                            }
                        }) {
                            Text(isEditing ? "Update" : "Create")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Spacer()
            }
            .padding(.vertical, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
//            VStack(spacing: 8) {
//                MacEditorTextView(
//                    text: $promptBody,
//                    isEditable: true,
//                    font: Fonts.nsFont(.defaultSize, .bold))
//            }
//            .padding(WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
        }
        .padding(16)
        .alert(errorMessage, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
    
    var background: some View {
        VStack(spacing: 0) {
            VisualEffectBackground(overlayColor: Color.background)
                .cornerRadius(8)
        }
        .padding(WindowComponent.Style.defaultContainerOuterPadding)
    }
}

extension PromptStudioEditorView {
    var commandView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Command")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                AppBlurView(size: .init(120, 60)) {
                    MacEditorTextView(
                        text: $promptCommand,
                        isEditable: true,
                        font: Fonts.nsFont(.defaultSize, .bold))
                }
                .frame(width: 120, height: 60)
                .padding(.horizontal, 16)
            }
            .onChange(of: promptCommand) { newValue in
                let sanitized = newValue.sanitized
                if newValue.utf8.count != sanitized.utf8.count {
                    promptCommand = sanitized
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                PopupableView(.promptStudio,
                              size: .init(200, 200),
                              edge: .maxX, {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(hex: promptColor))
                }) {
                    ColorPicker(hex: $promptColor)
                }
                .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Icon")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                PopupableView(.promptStudio,
                              size: .init(200, 300),
                              edge: .maxX, {
                    
                    AppBlurView(size: .init(0, 60)) {
                        Image(systemName: promptIcon)
                            .font(Fonts.live(.title, .bold))
                    }
                    .frame(width: 60, height: 60)
                }) {
                    SFSymbolsPicker(icon: $promptIcon)
                }
                .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack(spacing: 8) {
                    Label {
                        Text("Tune")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    } icon: {
                        Image (systemName: "rotate.3d")
                            .padding(.top, 2)
                    }
                    
                    Spacer()
                    
                }.frame(maxWidth: .infinity)
                
                tuneView
            }
            
            
            Spacer()
        }
    }
    
    var tuneView: some View {
        Group {
            if let customConfig = promptCustomConfig,
               session.isSubscribed {
                HStack(spacing: 8) {
                    PopupableView(.promptStudio,
                                  size: .init(460, 360),
                                  edge: .maxY, {
                        
                        AppBlurView(size: .init(0, 60),
                                    tintColor: Brand.Colors.purple.opacity(0.45)) {
                            Image(systemName: "gearshape")
                                .font(Fonts.live(.title, .bold))
                                .foregroundColor(.foreground)
                        }
                        .frame(width: 60, height: 60)
                        .environment(\.colorScheme, .dark)
                        
                    }) {
                        TuningView(isPopup: true, config: customConfig)
                            .attach({ config in
                                self.promptCustomConfig = config
                            }, at: \.setConfig)
                    }
                    .frame(width: 60, height: 60)
                    
                    AppBlurView(size: .init(0, 60),
                                tintColor: Brand.Colors.red.opacity(0.45)) {
                        Text("Reset")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }
                    .frame(height: 60)
                    .environment(\.colorScheme, .dark)
                    
                    Spacer()
                }
            } else {
                HStack(spacing: 16) {
                    AppBlurView(size: .init(60, 60)) {
                        Text(modeText)
                            .font(Fonts.live(.footnote, .bold))
                            .foregroundColor(.foreground)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 60, height: 60)
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .center) {
                        CustomSliderView(value: $promptCreativity,
                                         color: Brand.Colors.purple.opacity(0.45))
                        .frame(height: 30)
                        
                        PopupableView(.promptStudio,
                                      size: .init(460, 360),
                                      edge: .maxY, {
                            
                            Text("Advanced")
                                .font(Fonts.live(.footnote, .bold))
                                .foregroundColor(.foreground)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(Color.gray, lineWidth: 2)
                                        .padding(.horizontal, -6)
                                )
                                .padding(.horizontal, 6)
                            
                        }) {
                            TuningView(isPopup: true)
                                .attach({ config in
                                    self.promptCustomConfig = config
                                    InteractionManager.shared.closePopup(.init(kind: .promptStudio))
                                }, at: \.setConfig)
                        }
                    }
                }
            }
        }
    }
    
    var shortDescriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Short Description")
                .font(Fonts.live(.headline, .bold))
                .foregroundColor(.foreground)
            
            AppBlurView(size: .init(0, 60)) {
                MacEditorTextView(
                    text: $promptDescription,
                    isEditable: true,
                    font: Fonts.nsFont(.defaultSize, .bold))
            }
            .frame(height: 60)
        }
    }
    
    var roleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if session.isSubscribed {
                Text("Role")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                AppBlurView(size: .init(0, 60)) {
                    MacEditorTextView(
                        text: $promptRole,
                        isEditable: true,
                        font: Fonts.nsFont(.defaultSize, .bold))
                }
                .frame(height: 60)
            }
        }
    }
    
    var instructionsView: some View {
        ZStack {
            AppBlurView(size: .init(0, 240)) {
                MacEditorTextView(
                    text: $promptBody,
                    isEditable: true,
                    font: Fonts.nsFont(.defaultSize, .bold))
            }
            .frame(height: 240)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("\(promptTokenCount)/\(PromptService.customPromptMaxTokenCount)")
                        .font(Fonts.live(.caption, .bold))
                        .foregroundColor((promptTokenCount <= PromptService.customPromptMaxTokenCount ? Brand.Colors.green : Brand.Colors.red).opacity(0.55))
                    
                }
                
                Spacer()
                    .frame(height: WindowComponent.Style.defaultContainerOuterPadding)
            }
            .padding(8)
            .allowsHitTesting(false)
        }
        .frame(height: 240)
    }
}

extension PromptStudioEditorView {
    var exportButtonView: some View {
        AppBlurView(padding: .init(16)) {
            Button {
                if let dict = try? asCustomPrompt.toDictionaryPrompt() {
                    let stringV = "\(dict)"
                    
                    guard let pietaURL = Bundle.main.url(forResource: "pieta", withExtension: ".png") else { return }
                    guard let pieta = NSImage(contentsOf: pietaURL) else {
                        return
                    }
                    
                    guard let data = pieta.png else { return }
                    
                    let nsData = NSData(data: data)
                    
                    let bytes = getArrayOfBytesFromImage(imageData: nsData)
                    
                    let imageData = MarqueKit().encodeBytes(stringV, withObject: bytes).data
                    
                    let arraySize = MemoryLayout<UInt32>.size * imageData.count
                    
                    
                    let base64Data = Data(bytes: UnsafeRawPointer(imageData),
                                          count: arraySize)
                    
                    let base64String = data.base64EncodedString()
                    
                    print("[PromptStudioEditorView] encoded: \(imageData.count)")
                    let panel = NSSavePanel()
                    panel.nameFieldLabel = "Save prompt as:"
                    panel.nameFieldStringValue = "\(self.promptCommand).neatia"
                    panel.canCreateDirectories = true
                    panel.allowedContentTypes = [.init(exportedAs: "neatia"), .init(importedAs: "neatia")]
                    panel.begin { response in
                        if response == NSApplication.ModalResponse.OK,
                           let fileURL = panel.url {
                            
                            try? base64String.write(to: fileURL, atomically: true, encoding: .utf32)
                        }
                    }
                    
//                    if let decoded = ConfigService.decode(imageData) {
//                        print("[PromptStudioEditorView] decoded: \(decoded)")
//                    }
                }
//                guard sand.state.response.isNotEmpty else { return }
//                let markdown: String = sand.state.response
//                let parser = MarkdownParser()
//                let result = parser.parse(markdown)
//
//                let panel = NSSavePanel()
//                panel.nameFieldLabel = "Save generation as:"
//                panel.nameFieldStringValue = "neatia-\(Date().asStringWithTime).pdf"
//                panel.canCreateDirectories = true
//                panel.begin { response in
//                    if response == NSApplication.ModalResponse.OK,
//                       let fileURL = panel.url {
//                        createPDF(htmlString: result.html, url: fileURL)
//                    }
//                }
                
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
        AppBlurView(padding: .init(16)) {
            Button {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canCreateDirectories = false
                panel.allowedContentTypes = [.init(exportedAs: "neatia"), .init(importedAs: "neatia")]
                if panel.runModal() == .OK {
                    if let url = panel.url {
                        print("[PS] 1")
                        if let string = try? String(contentsOf: url) {
                            print("[PS] 2")
//                            let contents = string
//                                .components(separatedBy: ",")
//                                .compactMap( {
//                                    $0.replacingOccurrences(of: "[", with: "")
//                                    .replacingOccurrences(of: "]", with: "")
//                                    .newlinesSanitized
//
//                                }
//                            )
                            
                            
                            if let newData = Data(base64Encoded: string) {
                                let decodedString = String(data: newData, encoding: .utf32)
                                let count = decodedString?.components(separatedBy: ",").count ?? 0
                                print("[PS] 3 count: \(decodedString?.count)")
                                newData.withUnsafeBytes { (bytes: UnsafePointer<UInt32>) -> Void in
                                    let newArray = convert(count:count, data: bytes)
                                    print("[PS] After conversion, newArray = ", newArray.count)
                                }
                            } else {
                                fatalError("[PS] Failed to base-64 decode data!")
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

func convert<T>(count: Int, data: UnsafePointer<T>) -> [T] {
    let buffer = UnsafeBufferPointer(start: data, count: count);
    return Array(buffer)
}


fileprivate extension Encodable {

    /// Converting object to postable dictionary
    func toDictionaryPrompt(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
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
