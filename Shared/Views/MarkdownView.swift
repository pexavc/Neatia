////
////  MarkdownView.swift
////  Neatia
////
////  Created by Ritesh Pakala on 5/5/23.
////
//
//import Foundation
//import SwiftUI
//import SandKit
//
//struct MarkdownView: View {
//    @Environment(\.font) var font
//    @ScaledMetric(wrappedValue: 20) private var spacing
//
//    @State private var showCode: Bool = true
//    @State private var showHeadings: Bool = true
//    @State private var showImages: Bool = true
//    @State private var showQuotes: Bool = true
//    @State private var showThematicBreaks: Bool = true
//    @State private var showUnorderedBullets: Bool = true
//    @State private var showOrderedBullets: Bool = true
//    @State private var showCheckListBullets: Bool = true
//    @State private var showUnorderedItems: Bool = true
//    @State private var showOrderedItems: Bool = true
//    @State private var showCheckedItems: Bool = true
//    @State private var showLists: Bool = true
//
//    var markdown: String
//    var elementCount: ((Int) -> Void)
//    var padding: EdgeInsets
//    var isLazy: Bool
//
//    init(markdown: String,
//         padding: EdgeInsets = .init(0),
//         isLazy: Bool = true,
//         _ elementCount: @escaping((Int) -> Void)) {
//        self.markdown = markdown
//        self.elementCount = elementCount
//        self.padding = padding
//        self.isLazy = isLazy
//    }
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            if padding.top != .zero {
//                Spacer().frame(height: padding.top)
//            }
//            HStack {
//                if isLazy {
//                    LazyMarkdownText(markdown, paragraphSpacing: spacing, elementCount)
//                } else {
//                    MarkdownText(markdown, paragraphSpacing: spacing, elementCount)
//                }
//                Spacer(minLength: 0)
//            }
//            
//            if padding.bottom != .zero {
//                Spacer().frame(height: padding.bottom)
//            }
////            .padding(padding)
//        }
//        .markdownHeadingStyle(.custom)
//        .markdownQuoteStyle(.custom)
//        .markdownCodeStyle(.custom)
//        .markdownInlineCodeStyle(.custom)
//        .markdownOrderedListBulletStyle(.custom)
//        .markdownUnorderedListBulletStyle(.custom)
//        .markdownImageStyle(.custom)
//        .markdownParagraphStyle(.custom)
//        .markdownCode(showCode ? .visible : .hidden)
//        .markdownHeading(showHeadings ? .visible : .hidden)
//        .markdownImage(showImages ? .visible : .hidden)
//        .markdownQuote(showQuotes ? .visible : .hidden)
//        .markdownThematicBreak(showThematicBreaks ? .visible : .hidden)
//        .markdownUnorderedListItemBullet(showUnorderedBullets ? .visible : .hidden)
//        .markdownOrderedListItemBullet(showOrderedBullets ? .visible : .hidden)
//        .markdownCheckListItemBullet(showCheckListBullets ? .visible : .hidden)
//        .markdownUnorderedListItem(showUnorderedItems ? .visible : .hidden)
//        .markdownOrderedListItem(showOrderedItems ? .visible : .hidden)
//        .markdownCheckListItem(showCheckedItems ? .visible : .hidden)
//        .markdownList(showLists ? .visible : .hidden)
//        #if os(iOS)
//        .navigationBarTitleDisplayMode(.inline)
//        #endif
////        .navigationTitle(url.deletingPathExtension().lastPathComponent)
////        .toolbar {
////            Menu {
////                Toggle("Headings", isOn: $showHeadings.animation(.spring()))
////                Toggle("Blockquotes", isOn: $showQuotes.animation(.spring()))
////                Toggle("Code Blocks", isOn: $showCode.animation(.spring()))
////
////                Divider()
////
////                Toggle("Images", isOn: $showImages.animation(.spring()))
////                Toggle("Thematic Breaks", isOn: $showThematicBreaks.animation(.spring()))
////
////                Divider()
////
////                Toggle("Lists", isOn: $showLists.animation(.spring()))
////
////                Menu("List Bullets") {
////                    Toggle("Ordered", isOn: $showOrderedBullets.animation(.spring()))
////                    Toggle("Unordered", isOn: $showUnorderedBullets.animation(.spring()))
////                    Toggle("Checked", isOn: $showCheckListBullets.animation(.spring()))
////                }
////
////                Menu("List Items") {
////                    Toggle("Ordered", isOn: $showOrderedItems.animation(.spring()))
////                    Toggle("Unordered", isOn: $showUnorderedItems.animation(.spring()))
////                    Toggle("Checked", isOn: $showCheckedItems.animation(.spring()))
////                }
////            } label: {
////                Label("Visibility", systemImage: "ellipsis.circle")
////            }
////        }
//    }
//}
//
//struct CustomParagraph: ParagraphMarkdownStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .foregroundColor(.foreground)
//    }
//}
//
//extension ParagraphMarkdownStyle where Self == CustomParagraph {
//    static var custom: Self { .init() }
//}
//
//struct CustomHeading: HeadingMarkdownStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .foregroundColor(.foreground)
//    }
//}
//
//extension HeadingMarkdownStyle where Self == CustomHeading {
//    static var custom: Self { .init() }
//}
//
//struct Underline: StrikethroughMarkdownStyle {
//    func makeBody(configuration: Configuration) -> Text {
//        configuration.content.underline()
//    }
//}
//
//extension StrikethroughMarkdownStyle where Self == Underline {
//    static var custom: Self { .init() }
//}
//
//struct CustomInlineCode: InlineCodeMarkdownStyle {
//    func makeBody(configuration: Configuration) -> Text {
//        configuration.label
//            .foregroundColor(.foreground)
//    }
//}
//
//extension InlineCodeMarkdownStyle where Self == CustomInlineCode {
//    static var custom: Self { .init() }
//}
//
//struct CustomQuote: QuoteMarkdownStyle {
//    struct Content: View {
//        @ScaledMetric(wrappedValue: 20) private var padding
//        @ScaledMetric(wrappedValue: 3) private var thickness
//        @Environment(\.markdownParagraphStyle) private var style
//
//        let paragraph: ParagraphMarkdownConfiguration
//
//        var body: some View {
//            style
//                .makeBody(configuration: paragraph)
//                .font(.system(.callout, design: .rounded))
//                .foregroundColor(.secondaryForeground)
//                .padding(.horizontal, padding)
//                .overlay(
//                    RoundedRectangle(cornerRadius: thickness)
//                        .frame(width: thickness)
//                        #if os(iOS)
//                        .foregroundColor(.foreground)
//                        #endif
//                        .offset(x: thickness),
//                    alignment: .leading
//                )
//        }
//    }
//
//    func makeBody(configuration: Configuration) -> some View {
//        Content(paragraph: configuration.content)
//    }
//}
//
//extension QuoteMarkdownStyle where Self == CustomQuote {
//    static var custom: Self { .init() }
//}
//
//public struct CustomCode: CodeMarkdownStyle {
//    struct Label: View {
//        @ScaledMetric(wrappedValue: 15) private var padding
//
//        @State var lastCopiedText: String = ""
//        
//        var isCopied: Bool {
//            lastCopiedText == configuration.code
//        }
//        
//        let configuration: Configuration
//
//        var body: some View {
//            ScrollView(.horizontal, showsIndicators: false) {
//                configuration.label
//                    .padding(padding)
//            }
//            #if os(iOS)
//            .background(Color(.quaternarySystemFill).cornerRadius(8))
//            #endif
//            .background(Color.secondaryBackground.opacity(0.5).cornerRadius(8))
//            .overlay(
//                VStack(alignment: .trailing, spacing: 8) {
//                    configuration.language.flatMap { Text($0) }?
//                        .padding(5)
//                        .font(.footnote.weight(.semibold))
//                        .foregroundColor(.accentColor)
//                        //.foregroundColor(.secondary)
//                        #if os(iOS)
//                        .background(Color(.systemBackground))
//                        #endif
//                        .cornerRadius(6)
//                        .padding(.horizontal, 5)
//                        .padding(.top, 5)
//                    
//                    Button {
//                        lastCopiedText = configuration.code
//                        
//                        let pasteboard = NSPasteboard.general
//                        pasteboard.declareTypes([.string], owner: nil)
//                        pasteboard.setString(lastCopiedText, forType: .string)
//                    } label : {
//                        Image(systemName: "doc.on.clipboard\(isCopied ? ".fill" : "")")
//                            .font(Fonts.live(.headline, .bold))
//                            .frame(width: WindowComponent.Style.defaultElementSize.width,
//                                   height: WindowComponent.Style.defaultElementSize.height)
//                            .foregroundColor(.foreground)
//                            .environment(\.colorScheme, .dark)
//                            .padding(.bottom, 2)
//                            .background(Brand.Colors.black.opacity(0.3).cornerRadius(6))
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .frame(width: WindowComponent.Style.defaultElementSize.width,
//                           height: WindowComponent.Style.defaultElementSize.height)
//                    .padding(.trailing, 10)
//                    .padding(.top, 8)
//                },
//                alignment: .topTrailing
//            )
//            .environment(\.layoutDirection, .leftToRight)
//        }
//    }
//
//    public func makeBody(configuration: Configuration) -> some View {
//        Label(configuration: configuration)
//    }
//}
//
//extension CodeMarkdownStyle where Self == CustomCode {
//    static var custom: Self { .init() }
//}
//
//struct CustomOrderedBullet: OrderedListBulletMarkdownStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .foregroundColor(.foreground)
//    }
//}
//
//extension OrderedListBulletMarkdownStyle where Self == CustomOrderedBullet {
//    static var custom: Self { .init() }
//}
//
//struct CustomUnorderedBulletList: UnorderedListBulletMarkdownStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(Fonts.live(.caption, .bold))
//    }
//}
//
//extension UnorderedListBulletMarkdownStyle where Self == CustomUnorderedBulletList {
//    static var custom: Self { .init() }
//}
//
//struct CustomImage: ImageMarkdownStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//    }
//}
//
//extension ImageMarkdownStyle where Self == CustomImage {
//    static var custom: Self { .init() }
//}
