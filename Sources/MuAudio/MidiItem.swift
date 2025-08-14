//  created by musesum on 1/10/23.

import SwiftUI
import AVFoundation
import AudioKit
import MuFlo
import MuPeers

public enum MidiItemKind: Codable, Sendable {
    case noteOn(MidiNoteItem)
    case noteOff(MidiNoteItem)
    case controller(MidiControllerItem)
    case aftertouch(MidiAftertouchItem)
    case pitchbend(MidiPitchbendItem)
    case program(MidiProgramItem)
}

public struct MidiItem: Codable, Sendable {

    public let type: MidiType
    public let item: MidiItemKind?
    public let time: TimeInterval
    public let from: Int

    public init(_ type: MidiType, _ item: MidiItemKind?, _ share: Share) {
        self.type = type
        self.item = item
        self.time = Date().timeIntervalSince1970
        self.from = VisitType.midi.rawValue
        shareItem(share)
    }

    enum CodingKeys: String, CodingKey {
        case type, time, item, from
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type.stringValue, forKey: .type)
        try c.encode(time, forKey: .time)
        try c.encode(from, forKey: .from)
        if let item = item {
            try c.encode(item, forKey: .item)
        }
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        type = MidiType(rawValue: try c.decode(String.self, forKey: .type)) ?? .noteOn
        time = try c.decode(Double.self, forKey: .time)
        from = try c.decode(Int.self, forKey: .from)
        item = try c.decodeIfPresent(MidiItemKind.self, forKey: .item)
    }
    var visitFrom: VisitType {
        VisitType(rawValue: from)
    }
    func shareItem(_ share: Share) {
        Task {
            await share.peers.sendItem(.midiFrame) {
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
