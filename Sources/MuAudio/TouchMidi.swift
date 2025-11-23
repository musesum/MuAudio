//  created by musesum on 1/11/23.

import UIKit
import MuFlo 
import MuPeers

@MainActor
public class TouchMidi: @unchecked Sendable {

    static var midiKey = [Int: TouchMidi]()
    static var muMidi: MuMidi?
    private let buffer = CircleBuffer<MidiItem>()
    private let isRemote: Bool

    var midiRepeat = true /// repeat midi note sustain
    var lastItem: MidiItem? // repeat while sustain is on

    public init(isRemote: Bool) {

        self.isRemote = isRemote
        buffer.delegate = self
    }
}

extension TouchMidi: CircleBufferDelegate {

    public typealias Item = MidiItem

    public func flushItem<Item>(_ item: Item, _ from: DataFrom) -> BufState {
        let item = item as! MidiItem
        lastItem = item

        if isRemote || from == .remote {
            self.remoteMidiItem(item)
        } else {
            // local midi items already processed
        }
        return .nextBuf // never invalidate internal timer
    }
}
extension TouchMidi {

    public static func receiveItem(_ item: MidiItem, from: DataFrom) {
        if let touchMidi = midiKey[item.type.hashValue] {
            touchMidi.buffer.addItem(item, from: from)
        } else {
            let touchMidi = TouchMidi(isRemote: true)
            midiKey[item.type.hashValue] = touchMidi
            touchMidi.buffer.addItem(item, from: from)
        }
    }

    public func remoteMidiItem(_ item: MidiItem) {
        guard let kind = item.item else { return }
        guard let muMidi = TouchMidi.muMidi else { return }
        let flo = muMidi.listener.midiFlo
        let v = Visitor(0, item.visitFrom + .remote)
        switch kind {
        case .noteOn     (let i): flo.noteOnIn     (i.num,i.velo,i.chan,i.port,i.time,v)
        case .noteOff    (let i): flo.noteOffIn    (i.num,i.velo,i.chan,i.port,i.time,v)
        case .controller (let i): flo.controllerIn (i.cc, i.velo,i.chan,i.port,i.time,v)
        case .aftertouch (let i): flo.aftertouchIn (i.num,i.val, i.chan,i.port,i.time,v)
        case .pitchbend  (let i): flo.pitchwheelIn (      i.val, i.chan,i.port,i.time,v)
        case .program    (let i): flo.programIn    (i.num,       i.chan,i.port,i.time,v)
        }
    }
}
