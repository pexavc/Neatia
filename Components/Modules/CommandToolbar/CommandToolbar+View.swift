import Granite
import SwiftUI
import SandKit

extension CommandToolbar: View {
    public var view: some View {
        VStack {
            Spacer().frame(height: WindowComponent.Style.defaultComponentOuterPaddingContainerAware + WindowComponent.Style.defaultTitleBarHeight)
            
            ZStack(alignment: .trailing) {
                HStack(spacing: 8) {
                    leadingView
                    
                    Spacer()
                    
                    if prompt.hasSubcommand {
                        subcommandsView
                    }
                    
                    trailingView
                    
                }//HStack end, main container
                .frame(height: WindowComponent.Kind.toolbar.defaultSize.height)
                
            }//ZStack end
            
            Spacer()
                .allowsHitTesting(false)
        }.overlayIf(state.toggleDropdown, alignment: .topTrailing) {
            AppBlurView(size: .init(136, 136),
                        padding: .init(.zero),
                        tintColor: Brand.Colors.black.opacity(0.3)) {
                subcommandSelectionView
            }
            .frame(width: 136)
            //`0` is the sc index
            .offset(x: -1*((WindowComponent.Style.defaultElementSize.height + 8) + (indexOfSCSelected * 136) + (indexOfSCSelected * 8)), y: (WindowComponent.Style.defaultElementSize.height - 4) + WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
        }
    }
}

extension CommandToolbar {
    var subcommandSelectionView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 14)
            ScrollView([.vertical]) {
                TableView {
                    subcommandSelectionRows
                }.tableViewStyle(.init(rowHeight: WindowComponent.Style.defaultElementSize.height,
                                       showSeperators: false,
                                       paddingRow: .init(14),
                                       paddingTable: .init(0, 0)))
                .environment(\.colorScheme, .dark)
                
                Spacer().frame(height: 14)
            }
        }
    }
    
    var subcommandSelectionRows: [TableRow] {
        var list: [TableRow] = []
        
        for scv in subcommandValues {
            list.append(
                TableRow(text: .init("\(scv.id)", fontSize: .subheadline)) {
                    sand
                        .center
                        .setSubCommand
                        .send(SandService
                            .SetSubCommand
                            .Meta(id: state.scSelected,
                                  subcommandValueId: scv.id))
                    center.$state.binding.toggleDropdown.wrappedValue.toggle()
                }
            )
        }
        return list
    }
}

extension CommandToolbar {
    var leadingView: some View {
        Group {
            AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                Text("/" + command.capitalized)
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                    .environment(\.colorScheme, .dark)
            }
            
            
//            AppBlurView(tintColor: (sand.state.tokenCount <= promptType.maxTokens ? Brand.Colors.green : Brand.Colors.red).opacity(0.75)) {
//                Text("\(sand.state.tokenCount)/\(promptType.maxTokens) token limit")
//                    .font(Fonts.live(.subheadline, .bold))
//                    .foregroundColor(.foreground)
//            }
        }
    }
    
    var subcommandsView: some View {
        ScrollView([.horizontal]) {
            HStack(spacing: 8) {
                Spacer()
                
                ForEach(prompt.subCommands, id: \.id) { sc in
                    HStack(spacing: 8) {
                        if sand.state.subCommandSet?[sc.id]?.value.acceptsFile == true {
                            fileSelectionView(sc)
                        }
                        
                        AppBlurView(padding: .init(14, 0),
                                    tintColor: Brand.Colors.black.opacity(0.3)) {
                            HStack {
                                Text(sand.state.subCommandSet?[sc.id]?.value.id ?? "")
                                    .font(Fonts.live(.subheadline, .bold))
                                    .foregroundColor(.foreground)
                                    .environment(\.colorScheme, .dark)
                                    .padding(.bottom, 2)
                                
                                Spacer()
                                
                                Image(systemName: "arrowtriangle.\((state.toggleDropdown && sc.id == state.scSelected) ? "up" : "down").fill")
                                    .resizable()
                                    .frame(width: 9, height: 5)
                                    .font(Fonts.live(.subheadline, .bold))
                                    .foregroundColor(.foreground)
                                    .environment(\.colorScheme, .dark)
                                    .animation(.default, value: state.toggleDropdown)
                            }
                        }
                        .frame(width: 136, height: WindowComponent.Style.defaultElementSize.height)
                        .onTapGesture {
                            center.$state.binding.scSelected.wrappedValue = sc.id
                            center.$state.binding.toggleDropdown.wrappedValue.toggle()
                        }
                    }
                }
            }
            .rotationEffect(.init(degrees: 180))
        }
        .rotationEffect(.init(degrees: 180))
        .frame(maxHeight: .infinity)
    }
    
    func fileSelectionView(_ sc: any AnySubcommand) -> some View {
        
        let scValue = sand.state.subCommandSet?[sc.id]?.value
        
        let acceptedFileExtensions = scValue?.acceptedFileExtensions ?? []
        
        let baseEditorProperties: FileTextEditorView.Properties = .init(titleText: scValue?.fileDescription.capitalized ?? "Text Editor", maxTokenCount: scValue?.fileMaxTokenCount ?? SubcommandValue.defaultMaxTokenCount, isEditing: false, documentContents: "")
        
        if state.editorProperties == nil {
            center.$state.binding.editorProperties.wrappedValue = baseEditorProperties
        } else {
            center.$state.binding.editorProperties.wrappedValue?.isModifiable(true)
        }
        
        let fileProperties = center.state.editorProperties ?? baseEditorProperties
        
        let fileDescriptor = sand.state.subCommandFileSet?[sc.id]?[scValue?.id ?? ""]
        return AppBlurView(padding: .init(fileDescriptor == nil ? 8 : 14, 0),
                           tintColor: Brand.Colors.black.opacity(0.3)) {
            
                    PopupableView(.mount,
                                  size: .init(600, 600),
                                  edge: .maxY, {
                        
                        HStack(spacing: 8) {
                            if scValue != nil, let description = fileDescriptor {
                                
                                Text(description)
                                   .lineLimit(1)
                                   .font(Fonts.live(.subheadline, .bold))
                                   .foregroundColor(.foreground)
                                   .environment(\.colorScheme, .dark)
                                
                                Spacer()
                            }
                           
                            IconView(systemName: "doc.fill.badge.plus",
                                    withBlur: true)
                                .frame(width: WindowComponent.Style.defaultElementSize.height, height: WindowComponent.Style.defaultElementSize.height)
                       }
                    }) {
                        FileTextEditorView(fileProperties)
                            .attach({ output in
                                if output.isEditing == false {
                                    center.$state.binding.editorProperties.wrappedValue = nil
                                }
                            }, at: \.closeEditor)
                            .attach({ output in
                                if output.isEditing {
                                    center.$state.binding.editorProperties.wrappedValue?.updateContents(output.documentContents)
                                }
                                
                                //Update SandService
                                guard let contents = state.editorProperties?.documentContents else {
                                    return
                                }
                                sand
                                   .center
                                   .setSubCommandFileContents
                                   .send(SandService
                                       .SetSubCommandFileContents
                                       .Meta(id: sc.id,
                                             subcommandValueId: scValue?.id ?? "",
                                             contents: contents))
                            }, at: \.confirmEditor)
                    }
                    .frame(height: WindowComponent.Style.defaultElementSize.height)
            
               }
               .frame(width: fileDescriptor == nil ? WindowComponent.Style.defaultElementSize.height : 136, height: WindowComponent.Style.defaultElementSize.height)
               .padding(.trailing, fileDescriptor == nil ? 8 : 14)
               .animation(.default, value: fileDescriptor == nil)
               .alert("Only these file extensions are allowed: \(acceptedFileExtensions.joined(separator: ", "))", isPresented: center.$state.binding.showFileExtAlert) {
                   Button("OK", role: .cancel) { }
               }
        
    }
    
    var trailingView: some View {
        IconView(systemName: prompt.iconName,
                 bgColor: prompt.baseColor,
                 withBlur: true)
            .frame(width: WindowComponent.Style.defaultElementSize.height, height: WindowComponent.Style.defaultElementSize.height)
    }
}
