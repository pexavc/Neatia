// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/PianoRoll/
// PianoRoll.swift
import SwiftUI
import GlassKit

/// Touch-oriented piano roll.
///
/// Note: Requires macOS 12 / iOS 15 due to SwiftUI bug (crashes in SwiftUI when deleting notes).
public struct PianoRollView: View {
    public enum Layout {
        case horizontal
        case vertical
    }

    @Binding var model: PianoRollModel
    var editable: Bool
    var gridColor: Color
    var gridSize: CGSize
    var noteColor: Color
    var noteLineOpacity: Double
    var layout: Layout
    @State var isContinuous: Bool

    /// Initialize PianoRoll with a binding to a model and a color
    /// - Parameters:
    ///   - editable: Disable edition of any note in piano roll
    ///   - model: PianoRoll data
    ///   - noteColor: Color to use for the note indicator, defaults to system accent color
    ///   - noteLineOpacity: Opacity of the note view vertical black line
    ///   - gridColor: Color of grid
    ///   - gridSize: Size of a grid cell
    public init(
        editable: Bool = true,
        model: Binding<PianoRollModel>,
        noteColor: Color = .accentColor,
        noteLineOpacity: Double = 1,
        gridColor: Color = Color(red: 15.0 / 255.0, green: 17.0 / 255.0, blue: 16.0 / 255.0),
        gridSize: CGSize = CGSize(width: 80, height: 40),
        layout: Layout = .horizontal,
        isContinuous: Bool = false
    ) {
        _model = model
        self.noteColor = noteColor
        self.noteLineOpacity = noteLineOpacity
        self.gridSize = gridSize
        self.gridColor = gridColor
        self.editable = editable
        self.layout = layout
        self.isContinuous = isContinuous
    }

    private var width: CGFloat {
        CGFloat(model.length) * gridSize.width
    }

    private var height: CGFloat {
        CGFloat(model.height) * gridSize.height
    }

    /// SwiftUI view with grid and ability to add, delete and modify notes
    public var body: some View {
        ZStack(alignment: .topLeading) {
            let dragGesture = DragGesture(minimumDistance: 0).onEnded { value in
                let location = value.location
                var note: PianoRollNote
                switch layout {
                case .horizontal:
                    let step = Double(Int(location.x / gridSize.width))
                    let pitch = model.height - Int(location.y / gridSize.height)
                    note = PianoRollNote(start: step, length: 1, pitch: pitch, color: noteColor)
                case .vertical:
                    let step = Double(Int(location.y / gridSize.width))
                    let pitch = Int(location.x / gridSize.height)
                    note = PianoRollNote(
                        start: Double(model.length) - step - 1,
                        length: 1,
                        pitch: pitch + 1,
                        color: noteColor
                    )
                }
                model.notes.append(note)
            }
            PianoRollGrid(gridSize: gridSize, length: model.length, height: model.height, layout: layout, columnHighlight: $model.timestepColumnHighlight)
                .stroke(lineWidth: 0.5)
                .foregroundColor(gridColor)
                .contentShape(Rectangle())
                .gesture(editable ? TapGesture().sequenced(before: dragGesture) : nil)
            ForEach(model.notes) { note in
                switch layout {
                case .horizontal:
                    PianoRollNoteView(
                        note: $model.notes[model.notes.firstIndex(of: note)!],
                        gridSize: gridSize,
                        color: noteColor,
                        sequenceLength: model.length,
                        sequenceHeight: model.height,
                        isContinuous: isContinuous,
                        editable: editable,
                        lineOpacity: noteLineOpacity
                    ).onTapGesture {
                        guard editable else { return }
                        model.notes.removeAll(where: { $0 == note })
                    }

                case .vertical:
                    VerticalPianoRollNoteView(
                        note: $model.notes[model.notes.firstIndex(of: note)!],
                        gridSize: gridSize,
                        color: noteColor,
                        sequenceLength: model.length,
                        sequenceHeight: model.height,
                        isContinuous: isContinuous,
                        editable: editable,
                        lineOpacity: noteLineOpacity
                    ).onTapGesture {
                        guard editable else { return }
                        model.notes.removeAll(where: { $0 == note })
                    }
                }
            }
        }.frame(width: layout == .horizontal ? width : height,
                height: layout == .horizontal ? height : width)
    }
}
