//  Created by warren on 1/11/23.

import UIKit
import MuTime // DoubleBuffer

public protocol TouchRemoteMidiDelegate {
    func remoteMidiItem(_ midiItem: MidiItem)
}

public class TouchMidi {

    static var midiKey = [Int: TouchMidi]()
    public static var touchRemote: TouchRemoteMidiDelegate?
    private let buffer = DoubleBuffer<MidiItem>(internalLoop: true)
    private let isRemote: Bool

    var midiRepeat = true /// repeat midi note sustain
    var lastItem: MidiItem? // repeat while sustain is on


    public init(isRemote: Bool) {

        self.isRemote = isRemote
        buffer.flusher = self
    }
}

extension TouchMidi: BufferFlushDelegate {

    public typealias Item = MidiItem

    public func flushItem<Item>(_ item: Item) -> Bool {
        let item = item as! MidiItem
        lastItem = item

        if isRemote {
            TouchMidi.touchRemote?.remoteMidiItem(item)
        }
        return false // never invalidate internal timer
    }
}
extension TouchMidi {

    public static func remoteItem(_ item: MidiItem) {
        if let touchMidi = midiKey[item.type.hashValue] {
            touchMidi.buffer.append(item)
        } else {
            let touchMidi = TouchMidi(isRemote: true)
            midiKey[item.type.hashValue] = touchMidi
            touchMidi.buffer.append(item)
        }
    }
}
