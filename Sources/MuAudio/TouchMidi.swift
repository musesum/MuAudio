//  Created by warren on 1/11/23.

import UIKit
import MuTime // DoubleBuffer

public protocol TouchRemoteMidiDelegate {
    func remoteMidiItem(_ midiItem: MidiItem)
}

public class TouchMidi {

    static var midiKey = [Int: TouchMidi]()
    private let buffer = DoubleBuffer<MidiItem>(internalLoop: true)
    private let isRemote: Bool

    var midiRepeat = true /// repeat midi note sustain
    var lastItem: MidiItem? // repeat while sustain is on
    var touchRemote: TouchRemoteMidiDelegate?

    public init(isRemote: Bool, touchRemote: TouchRemoteMidiDelegate?) {

        self.isRemote = isRemote
        self.touchRemote = touchRemote
        buffer.flusher = self
    }
}

extension TouchMidi: BufferFlushDelegate {

    public typealias Item = MidiItem

    public func flushItem<Item>(_ item: Item) -> Bool {
        let item = item as! MidiItem
        lastItem = item

        if isRemote {
            touchRemote?.remoteMidiItem(item)
            //??? SkyVC.shared.midi?.remoteMidiItem(item)
        }
        return false // never invalidate internal timer
    }
}
extension TouchMidi {

    public static func remoteItem(_ item: MidiItem) {
        if let midi = midiKey[item.type.hashValue] {
            midi.buffer.append(item)
        } else {
            let touchMidi = TouchMidi(isRemote: true, touchRemote: nil) //???
            midiKey[item.type.hashValue] = touchMidi
            touchMidi.buffer.append(item)
        }
    }
}
