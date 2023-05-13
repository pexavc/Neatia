import Granite
import SwiftUI
import SandKit

extension Query: View {
    public var view: some View {
        VStack(spacing: 0) {
            //            Spacer().frame(height: Fonts.nsFont(.headline, .bold).actualHeight)
            
            ZStack(alignment: .top) {
                MacEditorTextView(
                    text: sand.center.$state.binding.query,
                    autoCompleteText: sand.center.$state.binding.commandAutoComplete,
                    isEditable: true,
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
                        print("[MacEditorTextView] onTab")
                        sand
                            .center
                            .setCommand
                            .send(
                                SandService
                                    .SetCommand
                                    .Meta(value: value, reset: false))
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
                
                if sand.state.query.isEmpty {
                    
                    MacEditorTextView(
                        text: .constant(helperText + "..."),
                        isEditable: false,
                        font: Fonts.nsFont(.headline, .regular)
                    )
                    .padding(.leading, 4)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                }
                
                if SandGPTTokenizerManager.tokenCount > 0 {
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("\(SandGPTTokenizerManager.tokenCount)/\(SandService.maxTokenCount)")
                                .font(Fonts.live(.caption, .bold))
                                .foregroundColor((SandGPTTokenizerManager.tokenCount <= SandService.maxTokenCount ? Brand.Colors.green : Brand.Colors.red).opacity(0.55))
                            
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
