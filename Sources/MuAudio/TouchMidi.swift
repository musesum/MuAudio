import UIKit
import MuFlo // DoubleBuffer

//nonisolated(unsafe) static var MidiKey = [Int: TouchMidi]()
//nonisolated(unsafe) let MidiRemote: MuMidi? = nil

//public class TouchMidi { //... rename MidiRemote
//
//    private let buffer = DoubleBuffer<MidiItem>(internalLoop: true)
//    private let isRemote: Bool
//
//    var lastItem: MidiItem? // repeat while sustain is on
//
//    public init() {
//        buffer.delegate = self
//    }
//}
//
//extension TouchMidi: DoubleBufferDelegate {
//
//    public typealias Item = MidiItem
//
//    public func flushItem<Item>(_ item: Item) -> Bool {
//        let item = item as! MidiItem
//        lastItem = item
//
//        MidiRemote?.remoteMidiItem(item)
//        return false // never invalidate internal timer
//    }
//}
//extension TouchMidi {
//
//    public static func remoteItem(_ item: MidiItem) {
//        TouchMidi.touchRemote?.remoteMidiItem(item)
//    }
//}
