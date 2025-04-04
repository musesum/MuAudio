//  MuMidi.swift
//  created by musesum on 9/19/20.

import Foundation
import AudioKit
import MuFlo

public class MuMidi {

    let listener: MuMidiListener

    public init(root: Flo) {

        listener = MuMidiListener(root)
        
        Midi.openInput()
        Midi.addListener(listener)
        Midi.openOutput()

        ccOutputZero() // not used
    }
    
    public func ccOutputZero() {

        let value = 120
        Task {
            for cc in 0...15 {

                Midi.sendControllerMessage(
                    MIDIByte(cc),
                    value: MIDIByte(value),
                    channel: MIDIChannel(0))
                try await Task.sleep(nanoseconds: 1_000)
            }
        }
    }

    /// received a midi event marshalled from Sky
    public func remoteMidiItem(_ item: MidiItem) {

        guard let any = item.item else { return }

        let flo = listener.midiFlo
        let visit = Visitor(0, item.visitFrom + .remote)

        switch item.type {
        case .noteOn:     if let i = any as? MidiNoteItem       { flo.noteOnIn        (i.num, i.velo, i.chan, i.port, i.time, visit) }
        case .noteOff:    if let i = any as? MidiNoteItem       { flo.noteOffIn       (i.num, i.velo, i.chan, i.port, i.time, visit) }
        case .controller: if let i = any as? MidiControllerItem { flo.controllerIn    (i.cc,  i.velo, i.chan, i.port, i.time, visit) }
        case .aftertouch: if let i = any as? MidiAftertouchItem { flo.aftertouchIn    (i.num, i.val,  i.chan, i.port, i.time, visit) }
        case .pitchbend:  if let i = any as? MidiPitchbendItem  { flo.pitchwheelIn    (       i.val,  i.chan, i.port, i.time, visit) }
        case .program:    if let i = any as? MidiProgramItem    { flo.programIn (i.num,         i.chan, i.port, i.time, visit) }
        }
    }
}
