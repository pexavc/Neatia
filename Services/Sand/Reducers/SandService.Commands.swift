import Granite
import SandKit
import Foundation
import PDFKit

extension SandService {
    struct ActivateCommands: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let isActive: Bool
        }
        
        @Payload var meta: Meta?
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            guard state.commandSet == nil else { return }
            
            environment
                .center
                .commandMenuActivated
                .send(
                    EnvironmentService
                        .CommandMenuActivated
                        .Meta(isActive: meta.isActive))
            
            if meta.isActive {
                state.commandAutoComplete = prompts.commands
            } else {
                state.commandAutoComplete = []
            }
        }
    }
    
    struct SetCommand: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let value: String
            let reset: Bool
        }
        
        @Payload var meta: Meta?
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            environment
                .center
                .commandToolbarActivated
                .send(
                    EnvironmentService
                        .CommandToolbarActivated
                        .Meta(isActive: meta.reset == false))
            
            state.commandSet = meta.reset ? nil : meta.value.lowercased().replacingOccurrences(of: "/", with: "")
            
            if let command = state.commandSet {
                if let basic = prompts.prompt(command) {
                    state.subCommandSet = [:]
                    state.subCommandFileSet = [:]
                    
                    for subcommand in basic.subCommands {
                        if let value = subcommand.values.first {
                            state.subCommandSet?[subcommand.id] = Prompts.subCommand(subcommand, scValue: value)
                            state.subCommandFileSet?[subcommand.id] = [:]
                        }
                    }
                }
                
                state.query = ""
            }
        }
    }
    
    struct SetSubCommand: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let id: String
            let subcommandValueId: String
        }
        
        @Payload var meta: Meta?
        
        @Relay var prompts: PromptService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            if let command = state.commandSet {
                if let basic = prompts.prompt(command) {
                    for subcommand in basic.subCommands {
                        if let value = subcommand.values.first(where: { $0.id == meta.subcommandValueId }) {
                            state.subCommandSet?[meta.id] = Prompts.subCommand(subcommand, scValue: value)
                        }
                    }
                }
            }
        }
    }
    
    struct SetSubCommandFile: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let id: String
            let subcommandValueId: String
            let fileURL: URL
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            state.subCommandFileSet?[meta.id]?[meta.subcommandValueId] = meta.fileURL
            
            //TODO: should be "smarter"
            if let scv = state.subCommandSet?[meta.id],
               scv.value.acceptsFile,
               scv.value.acceptedFileExtensions.contains(meta.fileURL.pathExtension.lowercased()) {
                
                var value = scv.value
                
                if let pdf = PDFDocument(url: meta.fileURL) {
                    let pageCount = pdf.pageCount
                    let documentContent = NSMutableAttributedString()

                    for i in 0 ..< pageCount {
                        guard let page = pdf.page(at: i) else { continue }
                        guard let pageContent = page.attributedString else { continue }
                        documentContent.append(pageContent)
                    }
                    
                    print("[SandService] [SetSCVFile] \(documentContent.string)")
                    
                    value.updateFileContents(documentContent.string)
                    state.subCommandSet?[meta.id] = Prompts.Subcommand(id: scv.id, value: value)
                } else {
                    print("[SandService] [SetSCVFile] error, couldn't create pdf")
                }
            } else {
                print("[SandService] [SetSCVFile] set command is nil? \(state.subCommandSet?[meta.id] == nil)")
            }
        }
        
        
    }
    
    struct Reset: GraniteReducer {
        typealias Center = SandService.Center
        
        func reduce(state: inout Center.State) {
            
            state.query = ""
            state.response = ""
            state.isResponding = false
            state.commandAutoComplete = []
            state.subCommandSet = nil
            state.subCommandFileSet = nil
            state.commandSet = nil
        }
    }
}

extension String {
    func suggestions(_ options: [String]) -> [String] {
        guard self.count > 1 else  { return [] }
        
        let text = self
        
        let textAfterCommand: String = String(text[text.index(after: text.startIndex)...])

        let isUppercased: Bool = textAfterCommand.first?.isUppercase == true
       
        let suggestions: [String] = options
            .filter {
                let range = $0.lowercased().range(of: textAfterCommand.lowercased())
                
                if let rangeCheck = range {
                    return rangeCheck.lowerBound == $0.startIndex
                } else {
                    return false
                }
                
            }.map {
                if isUppercased {
                    return ("/"+$0).capitalized
                } else {
                    return ("/"+$0).lowercased()
                }
            }
        
        return suggestions
    }
}
