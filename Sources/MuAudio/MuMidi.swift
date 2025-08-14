//  MuMidi.swift
//  created by musesum on 9/19/20.

import Foundation
import AudioKit
import MuFlo
import MuPeers

public class MuMidi {

    let listener: MuMidiListener
    let midi: MIDI

    public init(_ midi: MIDI,
                _ root: Flo,
                _ peers: Peers) {

        self.midi = midi
        listener = MuMidiListener(midi, root, peers)

        midi.openInput()
        midi.addListener(listener)
        midi.openOutput()
        ccOutputZero() // not used?
    }
    
    public func ccOutputZero() {
        let value = 120
        for cc in 0...15 {
            self.midi.sendControllerMessage(
                MIDIByte(cc),
                value: MIDIByte(value),
                channel: MIDIChannel(0))
        }
    }
}
