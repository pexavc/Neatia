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
        var cases: [Prompts] = Prompts.allCases
        var sortedCases: [Prompts] = []
        if sand.state.query.hasPrefix("/") {
            let suggestions: [String] = sand.state.query.suggestions(sand.state.commandAutoComplete).map { String($0.lowercased().suffix($0.count - 1)) }
            
            cases.removeAll(where: { suggestions.contains($0.rawValue) })
            sortedCases = Array(suggestions.map { .init(rawValue: $0.lowercased()) ?? .empty }) + cases
        }
        
        for prompt in sortedCases.isEmpty ? cases : sortedCases {
            list.append(
                TableRow(text: .init("/\(prompt.rawValue.capitalized)...",
                                     subLeading: .init("\(Prompts.all[prompt]?.description ?? "")")),
                         graphic: .init(Prompts.all[prompt]?.iconName ?? "",
                                        leadingBGColor: Prompts.all[prompt]?.baseColor ?? Brand.Colors.black)) {
                    sand
                        .center
                        .setCommand
                        .send(
                            SandService
                                .SetCommand
                                .Meta(value: prompt.rawValue, reset: false))
                }
            )
        }
        return list
    }
}

