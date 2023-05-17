import Granite
import SwiftUI
import SandKit

extension CommandMenu: View {
    public var view: some View {
        VStack {
            ScrollView([.vertical]) {
                Spacer()
                
                TableView {
                    rows
                }.tableViewStyle(.init(rowHeight: WindowComponent.Style.commandMenuElementHeight,
                                       showSeperators: false,
                                       paddingRow: .init(WindowComponent.Style.defaultComponentOuterPaddingContainerAware, 0),
                                       paddingTable: .init(WindowComponent.Style.defaultContainerOuterPadding, 0)))
                .animation(.default, value: sand.state.query.count)
                
                Spacer()
            }
        }
    }
    
    var rows: [TableRow] {
        var list: [TableRow] = []
        var cases: [String] = prompts.commands
        var sortedCases: [String] = []
        if sand.state.query.hasPrefix("/") {
            let suggestions: [String] = sand.state.query.suggestions(sand.state.commandAutoComplete).map { String($0.lowercased().suffix($0.count - 1)) }
            
            cases.removeAll(where: { suggestions.contains($0.lowercased()) })
            sortedCases = Array(suggestions.map { $0 }) + cases
        }
        
        for command in sortedCases.isEmpty ? cases : sortedCases {
            let prompt = prompts.prompt(command)
            let isLocked = prompt?.isSystemPrompt == true && session.isSubscribed == false
            let labelText: LocalizedStringKey? = isLocked ? .init("subscribe") : (prompt?.isSystemPrompt == true ? nil : .init("custom"))
            list.append(
                TableRow(kind: .label(isLocked ? Color.gray : Color.orange),
                        text: .init("/\(command.capitalized)...",
                                     subLeading: .init("\(prompt?.description ?? "")"),
                                     trailing: labelText),
                         graphic: .init(prompt?.iconName ?? "",
                                        leadingBGColor: prompt?.baseColor ?? Brand.Colors.black,
                                        texture: prompt?.isSystemPrompt == true)) {
                    sand
                        .center
                        .setCommand
                        .send(
                            SandService
                                .SetCommand
                                .Meta(value: command, reset: false))
                }
            )
        }
        return list
    }
}

