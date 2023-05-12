// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/PianoRoll/

import SwiftUI
import GlassKit
import AudioKit
import Tonic
import Combine
import Granite

/// Value oriented data model for `PianoRoll`
///
/// The data model is abstracted away from MIDI so that it's up to you
/// to determine what pitch means (e.g. how it is scale quantized).
public struct PianoRollModel: GraniteModel {
    
    
    
    public static var simpleCMajScale: [MIDINoteData] = [
        MIDINoteData(noteNumber: 60, position: .init(beats: 0), duration: .init(beats: 3)),
        MIDINoteData(noteNumber: 62, position: .init(beats: 1), duration: .init(beats: 3)),
        MIDINoteData(noteNumber: 64, position: .init(beats: 2), duration: .init(beats: 3)),
        MIDINoteData(noteNumber: 65, position: .init(beats: 3), duration: .init(beats: 3)),
        MIDINoteData(noteNumber: 67, position: .init(beats: 4), duration: .init(beats: 3)),
        MIDINoteData(noteNumber: 69, position: .init(beats: 5), duration: .init(beats: 3)),
        MIDINoteData(noteNumber: 71, position: .init(beats: 6), duration: .init(beats: 3)),
        MIDINoteData(noteNumber: 72, position: .init(beats: 7), duration: .init(beats: 3))
    ]
    
    public var timestepColumnHighlight: Int = -1
    
    /// Initialize the PianoRollModel an array of PianoRollNotes, and dimensions
    /// - Parameters:
    ///   - notes: The sequence being edited
    ///   - length: Duration in steps
    ///   - height: The number of pitches representable
    public init(notes: [PianoRollNote], length: Int, height: Int, key: Key = .C) {
        self.length = length
        self.height = height
        self.key = key
        self._notes = notes.map { note in
            var keyedNote = note
            keyedNote.key = key
            return keyedNote
        }
    }
    
    public var key: Key {
        didSet {
            // Triggers notes to reassign themselves
            // the latest key via the notes setter.
            notes = _notes
        }
    }
    
    /// The sequence being edited
    public var notes: [PianoRollNote] {
        get { return _notes }
        
        set(newNotes) {
            _notes = newNotes.map { note in
                var keyedNote = note
                keyedNote.key = key
                return keyedNote
            }
            //print("Notes: \(_notes)")
            //self.currentNotes.send(_notes)
        }
    }
    
    /// Proxy storage for `notes` property of `PianoRollModel`.  Avoid using directly, instead accessing the `notes` property.
    private var _notes: [PianoRollNote] {
        didSet {
            self.currentNotes.send(_notes)
        }
    }
    
    
    /// Duration in steps
    public var length: Int
    
    /// The number of pitches represented
    public var height: Int
    
    lazy var currentNotes: PassthroughSubject<[PianoRollNote], Never> = {
        .init()
    }()
    
    public lazy var midiNotesPublisher: AnyPublisher <[MIDINoteData], Never> = currentNotes
        .removeDuplicates()
        .map { pianoRollNotes in
            pianoRollNotes.map({MIDINoteData(noteNumber: MIDINoteNumber($0.note.noteNumber), position: .init(beats: $0.start), duration: .init(beats: $0.length) )})
        }
        .eraseToAnyPublisher()
    
    
    
    public mutating func updateModelWithMIDINotes(_ midiNotes: [MIDINoteData], keepExisting: Bool = true) {
        let pianoRollNotes = midiNotes.map { midiNote -> PianoRollNote in
            let start = midiNote.position.beats
            let length = midiNote.duration.beats
            let pitch = Int(midiNote.noteNumber)
            return PianoRollNote(start: start, length: length, pitch: pitch, color: nil, key: key)
        }
        
        //TODO: improve the effeciency of the logic here
        if !keepExisting {
            /// Note: Although the data is already formatted suitably for assignment directly to `_notes`,
            /// __doing so would skip the publisher update__, which is associated with the setter method on the `notes` property
            self.notes = pianoRollNotes
        }
        self.notes.append(contentsOf: pianoRollNotes)
        
        
    }
    
    enum CodingKeys: CodingKey {
        case length
        case height
        case _notes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let length: Int? = try container.decode(Int.self, forKey: .length)
        
        let height: Int? = try container.decode(Int.self, forKey: .height)
        
        let _notes: [PianoRollNote]? = try container.decode([PianoRollNote].self, forKey: ._notes)
        
        self.init(notes: _notes ?? [], length: length ?? 0, height: height ?? 0)
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let length = length as? Int {
            try container.encode(length, forKey: .length)
        }
        
        if let height = height as? Int {
            try container.encode(height, forKey: .height)
        }
        
        if let notes = notes as? [PianoRollNote] {
            try container.encode(notes, forKey: ._notes)
        }
    }
    
}

public extension MIDINoteData {
    init(noteNumber: MIDINoteNumber, position: Duration, duration: Duration, velocity: MIDIVelocity = 90, channel: MIDIChannel = 0) {
        self.init(noteNumber: noteNumber, velocity: velocity, channel: channel, duration: duration, position: position)
    }
}
