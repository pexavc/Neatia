import Granite
import SwiftUI
import SandKit

extension Query: View {
    public var view: some View {
        VStack(spacing: 0) {
            //            Spacer().frame(height: Fonts.nsFont(.headline, .bold).actualHeight)
            
            ZStack(alignment: .top) {
                if session.isLocked {
                    MacEditorTextView(
                        text: .constant(""),
                        isEditable: false,
                        font: Fonts.nsFont(.defaultSize, .bold))
                        .overlay(Color.clear)
                } else {
                    MacEditorTextView(
                        text: query.center.$state.binding.value,
                        autoCompleteText: sand.center.$state.binding.commandAutoComplete,
                        font: Fonts.nsFont(.defaultSize, .bold),
                        onEditingChanged: {
                            center.$state.binding.wrappedValue.isEditing = true
                        },
                        onCommit: {
                            guard environment.center.state.isCommandActive == false else {
                                return
                            }
                            
                            sand.center.ask.send()
                        },
                        onTabComplete: { value in
                            //Check for environment commands
                            if value.hasPrefix("/"),
                               let first = value.lowercased().newlinesSanitized.suggestions(sand.state.commandAutoComplete).first,
                               let envCommand = prompts.environmentCommand(first.lowercased().replacingOccurrences(of: "/", with: "")) {
                                switch envCommand {
                                case .reset:
                                    sand.center.reset.send()
                                    environment.center.reset.send()
                                }
                                
                            //Normal command set flow
                            } else {
                                sand
                                    .center
                                    .setCommand
                                    .send(
                                        SandService
                                            .SetCommand
                                            .Meta(value: value, reset: false))
                            }
                            
                        },
                        lineCountUpdated: { lineCount in
                            environment
                                .center
                                .queryWindowSize
                                .send(
                                    EnvironmentService
                                        .QueryWindowSizeUpdated
                                        .Meta(lineCount: lineCount))
                        },
                        commandMenuActive: { isActive in
                            sand
                                .center
                                .activateCommands
                                .send(
                                    SandService
                                        .ActivateCommands
                                        .Meta(isActive: isActive))
                        }
                    )
                    .alert(sand.state.lastError?.message ?? "", isPresented: sand.center.$state.binding.errorExists) {
                        Button("OK", role: .cancel) { }
                    }
                }
                
                if query.state.value.isEmpty {
                    
                    MacEditorTextView(
                        text: .constant(helperText + "..."),
                        isEditable: false,
                        font: Fonts.nsFont(.headline, .regular)
                    )
                    .padding(.leading, 4)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                }
                
                if SandGPTTokenizerManager.tokenCount > 0 &&
                    SandGPTTokenizerManager.shared.pause == false {
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("\(SandGPTTokenizerManager.shared.tokenCount)/\(maxTokenCount)")
                                .font(Fonts.live(.caption, .bold))
                                .foregroundColor((SandGPTTokenizerManager.tokenCount <= maxTokenCount ? Brand.Colors.green : Brand.Colors.red).opacity(0.55))
                            
                        }
                        
                        Spacer()
                            .frame(height: WindowComponent.Style.defaultContainerOuterPadding)
                    }
                    .allowsHitTesting(false)
                }
            }
        }
    }
}
