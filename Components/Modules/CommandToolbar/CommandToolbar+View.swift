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
                Text("/" + promptType.rawValue.capitalized)
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
        
        let acceptedFileExtensions = sand.state.subCommandSet?[sc.id]?.value.acceptedFileExtensions ?? []
        
        let scValue = sand.state.subCommandSet?[sc.id]?.value
        let url = sand.state.subCommandFileSet?[sc.id]?[scValue?.id ?? ""]
        return AppBlurView(padding: .init(url == nil ? 8 : 14, 0),
                           tintColor: Brand.Colors.black.opacity(0.3)) {
                    HStack(spacing: 8) {
                        if scValue != nil, let fileUrl = url {
                            
                            Text(fileUrl.lastPathComponent)
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
               }
               .frame(width: url == nil ? WindowComponent.Style.defaultElementSize.height : 136, height: WindowComponent.Style.defaultElementSize.height)
               .padding(.trailing, url == nil ? 8 : 14)
               .animation(.default, value: url == nil)
               .onTapGesture {
                   let panel = NSOpenPanel()
                   panel.allowsMultipleSelection = false
                   panel.canChooseDirectories = false
                   if panel.runModal() == .OK {
                       let url = panel.url
                       let fileExt = panel.url?.pathExtension
                       let fileName = panel.url?.lastPathComponent
                       
                       if acceptedFileExtensions.contains((fileExt ?? "").lowercased()),
                          let fileURL = url {
                           
                           sand
                               .center
                               .setSubCommandFile
                               .send(SandService
                                   .SetSubCommandFile
                                   .Meta(id: sc.id,
                                         subcommandValueId: sand.state.subCommandSet?[sc.id]?.value.id ?? "",
                                         fileURL: fileURL))
                       } else {
                           center.$state.binding.showAlert.wrappedValue.toggle()
                       }
                       print("[CommandToolbar] file selected: \(fileExt)")
                   }
               }.alert("Only these file extensions are allowed: \(acceptedFileExtensions.joined(separator: ", "))", isPresented: center.$state.binding.showAlert) {
                   Button("OK", role: .cancel) { }
               }
               .alert(sand.state.lastError?.message ?? "", isPresented: sand.center.$state.binding.errorExists) {
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
