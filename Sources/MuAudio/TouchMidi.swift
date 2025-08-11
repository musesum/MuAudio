//  created by musesum on 1/11/23.

import UIKit
import MuFlo 

public protocol TouchRemoteMidiDelegate {
    func remoteMidiItem(_ midiItem: MidiItem)
}
@MainActor
public class TouchMidi: @unchecked Sendable {

    static var midiKey = [Int: TouchMidi]()
    static var touchRemote: TouchRemoteMidiDelegate?
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

    public func flushItem<Item>(_ item: Item, _ type: BufType) -> BufState {
        let item = item as! MidiItem
        lastItem = item

        if isRemote || type == .remoteBuf {
            TouchMidi.touchRemote?.remoteMidiItem(item)
        } else {
            // local midi items already processed
        }
        return .nextBuf // never invalidate internal timer
    }
}
extension TouchMidi {

    public static func remoteItem(_ item: MidiItem) {
        if let touchMidi = midiKey[item.type.hashValue] {
            touchMidi.buffer.addItem(item, bufType: .remoteBuf)
        } else {
            let touchMidi = TouchMidi(isRemote: true)
            midiKey[item.type.hashValue] = touchMidi
            touchMidi.buffer.addItem(item, bufType: .remoteBuf)
        }
    }
}
