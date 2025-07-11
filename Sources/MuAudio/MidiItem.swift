//  created by musesum on 1/10/23.

import SwiftUI
import AVFoundation
import AudioKit
import MuFlo
import MuPeers

public struct MidiItem: Codable, @unchecked Sendable {

    public let type: MidiType
    public let item: Any?
    public let time: TimeInterval
    public let from: Int

    public init(_ type: MidiType, _ item: Any?, _ peers: Peers) {
        self.type = type
        self.item = item
        self.time = Date().timeIntervalSince1970
        self.from = VisitType.midi.rawValue
        sendItemToPeers(peers)
    }

    enum CodingKeys: String, CodingKey {
        case type, time, item, from }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type.stringValue, forKey: .type)
        try c.encode(time, forKey: .time)
        try c.encode(from, forKey: .from)
        switch type {
        case .noteOn     : try c.encode(item as? MidiNoteItem,       forKey: .item)
        case .noteOff    : try c.encode(item as? MidiNoteItem,       forKey: .item)
        case .controller : try c.encode(item as? MidiControllerItem, forKey: .item)
        case .aftertouch : try c.encode(item as? MidiAftertouchItem, forKey: .item)
        case .pitchbend  : try c.encode(item as? MidiPitchbendItem,  forKey: .item)
        case .program    : try c.encode(item as? MidiProgramItem,    forKey: .item)
        }
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        type = MidiType(rawValue: try c.decode(String.self, forKey: .type)) ?? .noteOn
        time = try c.decode(Double.self, forKey: .time)
        from = try c.decode(Int   .self, forKey: .from)

        switch type {
        case .noteOn     : try item = c.decode(MidiNoteItem      .self, forKey: .item)
        case .noteOff    : try item = c.decode(MidiNoteItem      .self, forKey: .item)
        case .controller : try item = c.decode(MidiControllerItem.self, forKey: .item)
        case .aftertouch : try item = c.decode(MidiAftertouchItem.self, forKey: .item)
        case .pitchbend  : try item = c.decode(MidiPitchbendItem .self, forKey: .item)
        case .program    : try item = c.decode(MidiProgramItem   .self, forKey: .item)
        }
    }
    var visitFrom: VisitType {
        VisitType(rawValue: from)
    }
    func sendItemToPeers(_ peers: Peers) {
        Task {
            await peers.sendItem(.midiFrame) {
                do {
                    return try JSONEncoder().encode(self)
                } catch {
                    print(error)
                    return nil
                }
            }
        }
    }
}
