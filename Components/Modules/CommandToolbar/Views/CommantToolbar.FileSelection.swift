//
//  CommantToolbar.FileSelection.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/15/23.
//

import Foundation
import SwiftUI
import Granite
import SandKit

extension CommandToolbar {
    func fileSelectionView(_ sc: any AnySubcommand) -> some View {
        
        let scValue = sand.state.subCommandSet?[sc.id]?.value
        
        let acceptedFileExtensions = scValue?.acceptedFileExtensions ?? []
        
        let baseEditorProperties: FileTextEditorView.Properties = .init(titleText: scValue?.fileDescription.capitalized ?? "Text Editor", maxTokenCount: scValue?.fileMaxTokenCount ?? SubcommandValue.defaultMaxTokenCount, isEditing: false, documentContents: "")
        
        if state.editorProperties == nil {
            center.$state.binding.editorProperties.wrappedValue = baseEditorProperties
        } else if state.editorProperties?.documentContents.isNotEmpty == true {
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
                                InteractionManager.shared.closePopup(.init(kind: .mount))
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
                                
                                InteractionManager.shared.closePopup(.init(kind: .mount))
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
}
