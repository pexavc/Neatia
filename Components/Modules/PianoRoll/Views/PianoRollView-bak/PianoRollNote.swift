// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/PianoRoll/
// PianoRollNote.swift
import SwiftUI
import Tonic
import Granite

/// Individual note displayed on the PianoRoll
public struct PianoRollNote: GraniteModel, Identifiable {
    /// Initialize the PianoRollNote with start time, duration, and pitch
    /// - Parameters:
    ///   - start: The start step
    ///   - length: Duration, measured in steps
    ///   - pitch: Abstract pitch, not MIDI notes.
    ///   - text: Optional text shown on the note view.
    ///   - color: Individual note color. It will default to `noteColor` in `PianoRoll` if not set.
    public init(start: Double, length: Double, pitch: Int, text: String? = nil, color: Color? = nil, key: Key = .C) {
        self.start = start
        self.length = length
        self.pitch = pitch
        self.color = color
        self.key = key
        self.note = Pitch(intValue: max(0, pitch)).note(in: key)
        self.text = note.description
        self.color = Color(cgColor: Self.colorMap[Int(note.pitch.pitchClass)])
        
    }
    /// Unique Identifier
    public var id = UUID()
    
    /// The start step
    public var start: Double
    
    /// Duration, measured in steps
    public var length: Double
    
    /// The current key that the composition is in
    public var key: Key {
        mutating didSet {
            note = Pitch(intValue: max(0, pitch)).note(in: key)
            text = note.description
            color = Color(cgColor: Self.colorMap[Int(note.pitch.pitchClass)])
            
        }
    }
    
    /// Abstract pitch, not MIDI notes.
    public var pitch: Int {
        mutating didSet {
            note = Pitch(intValue: max(0, pitch)).note(in: key)
            text = note.description
            color = Color(cgColor: Self.colorMap[Int(note.pitch.pitchClass)])
            
            //            let oct = (note.pitch.midiNoteNumber / 127).clamped(to: 0...1)
            //            let col = PitchColor.jameson[Int(note.pitch.pitchClass)].components!
            //            let cgCol = CGColor(red: col[0], green: col[1], blue: col[2], alpha: max(0.1, CGFloat(oct)))
            //            color = Color(cgColor: cgCol)
            
        }
    }
    
    /// The abstract pitch that has been quantized to a concrete Note in the current musical Key.
    public private(set) var note: Note
    
    /// The array of 12 colors to use for mapping pitches (0 - 127) into pitch classes
    public static var colorMap: [CGColor] = PitchColor.jameson
    
    /// Optional text shown on the note view
    public var text: String?
    /// Individual note color. It will default to `noteColor` in `PianoRoll` if not set.
    public var color: Color?
    
    enum CodingKeys: CodingKey {
        case id
        case start
        case length
        case pitch
        case text
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id: UUID? = try container.decode(UUID.self, forKey: .id)
        
        let start: Double? = try container.decode(Double.self, forKey: .start)
        
        let length: Double? = try container.decode(Double.self, forKey: .length)
        let pitch: Int? = try container.decode(Int.self, forKey: .pitch)
        let text: String? = try container.decode(String.self, forKey: .text)
        
        self.init(start: start ?? 0, length: length ?? 0, pitch: pitch ?? 0)
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id as? UUID {
            try container.encode(id, forKey: .id)
        }
        
        if let start = start as? Double {
            try container.encode(start, forKey: .start)
        }
        
        if let length = length as? Double {
            try container.encode(length, forKey: .length)
        }
        
        if let pitch = pitch as? Int {
            try container.encode(pitch, forKey: .pitch)
        }
        
        if let text = text as? String {
            try container.encode(text, forKey: .text)
        }
    }
    
}
