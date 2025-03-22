//  MidiFlo.swift
//  created by musesum on 11/4/22.

import Foundation
import AudioKit
import AVFoundation
import MuFlo

class MidiFlo {
    
    let midi = MIDI.sharedInstance

    // input
    var noteOnIn˚     : Flo
    var noteOffIn˚    : Flo
    var controllerIn˚ : Flo
    var afterTouchIn˚ : Flo
    var pitchBendIn˚  : Flo
    var programIn˚    : Flo
    var nrpnIn˚       : Flo

    // output
    var noteOnOut˚     : Flo?
    var noteOffOut˚    : Flo?
    var controllerOut˚ : Flo?
    var afterTouchOut˚ : Flo?
    var pitchBendOut˚  : Flo?
    var programOut˚    : Flo?
    var nrpnOut˚       : Flo?

    // Non-Registered Parameter Number (fine precision)
    var nrpnNumMsb: Float = -1
    var nrpnNumLsb: Float = -1
    var nrpnValMsb: Float = -1
    var nrpnValLsb: Float = -1
    
    public var setOptions: SetOptions = .fire
    
    init(_ root: Flo) {
        
        let midi      = root.bind("midi")
        let input     = midi.bind("input")
        noteOnIn˚     = input.bind("note.on"   )
        noteOffIn˚    = input.bind("note.off"  )
        controllerIn˚ = input.bind("controller")
        afterTouchIn˚ = input.bind("afterTouch")
        pitchBendIn˚  = input.bind("pitchBend" )
        programIn˚    = input.bind("program"   )
        nrpnIn˚       = input.bind("nrpn"      )

        let output     = midi.bind("output")
        noteOnOut˚     = output.bind("note.on"   ) { f,v in self.noteOnOut    (f,v) }
        noteOffOut˚    = output.bind("note.off"  ) { f,v in self.noteOffOut   (f,v) }
        controllerOut˚ = output.bind("controller") { f,v in self.controllerOut(f,v) }
        afterTouchOut˚ = output.bind("afterTouch") { f,v in self.aftertouchOut(f,v) }
        pitchBendOut˚  = output.bind("pitchBend" ) { f,v in self.pitchbendOut (f,v) }
        programOut˚    = output.bind("program"   ) { f,v in self.programOut   (f,v) }
        nrpnOut˚       = output.bind("nrpn"      )
    }
    // MARK: - output

    /// `.noteOn     (num, velo, chan, port, time)`
    /// `.noteOff    (num, velo, chan, port, time)`
    /// `.controller (cc,  velo, chan, port, time)`
    /// `.aftertouch (num, val,  chan, port, time)`
    /// `.pitchwheel (     val,  chan, port, time)`
    /// `.program    (num,       chan, port, time)`

    func noteOnOut(_ flo: Flo,
                   _ visit: Visitor) {

        guard let exprs = flo.exprs else { return }
        
        if let num  = exprs["num",  .tween],
           let velo = exprs["velo", .tween],
           let chan = exprs["chan", .tween] {

            midi.sendNoteOnMessage(
                noteNumber: MIDINoteNumber(num),
                velocity: MIDIVelocity(velo),
                channel: MIDIChannel(chan))
        }
        
    }
    func noteOffOut(_ flo: Flo,
                    _ visit: Visitor) {

        guard let exprs = flo.exprs else { return }
        
        if let num  = exprs["num",  .tween],
           let chan = exprs["chan", .tween],
           let time = exprs["time", .tween] {

            midi.sendNoteOffMessage(
                noteNumber: MIDINoteNumber(num),
                channel: MIDIChannel(chan),
                time: MIDITimeStamp (time))
        }
        
    }
    func controllerOut(_ flo: Flo,
                       _ visit: Visitor) {

        guard let exprs = flo.exprs else { return }

        if let cc   = exprs["cc",   .tween],
           let val  = exprs["val",  .tween],
           let chan = exprs["chan", .tween] {

            //print ("🎚\(cc.digits(0)) ⫸ \(val.digits(0...2)) \(flo.path(2)): \(visit.type.log)\(flo.exprs?.logVisitedPaths(visit) ?? "")")

            Task {
                midi.sendNoteOnMessage(
                    noteNumber: MIDINoteNumber(val),
                    velocity: MIDIVelocity(64),
                    channel: MIDIChannel(chan))

                try await Task.sleep(nanoseconds: 100_000_000) // 1/10th sec

                midi.sendNoteOffMessage(
                    noteNumber: MIDINoteNumber(val),
                    channel: MIDIChannel(chan))
            }

//            midi.sendControllerMessage(
//                MIDIByte(cc),
//                value: MIDIByte(val),
//                channel: MIDIChannel(0))

        }
    }
    func aftertouchOut(_ flo: Flo,
                       _ visit: Visitor) {
        //guard let exprs = flo.exprs else { return }

    }
    func pitchbendOut(_ flo: Flo,
                      _ visit: Visitor) {

        guard let exprs = flo.exprs else { return }

        if let val  = exprs["val",  .tween],
           let chan = exprs["chan", .tween] {

            midi.sendPitchBendMessage(
                value: UInt16(val),
                channel: MIDIChannel(chan))
        }
    }
    func programOut(_ flo: Flo,
                    _ visit: Visitor) {
        //guard let exprs = flo.exprs else { return }
        
    }
    // MARK: - input
    func noteOnIn(_ num: MIDINoteNumber,
                  _ velo: MIDIVelocity,
                  _ chan: MIDIChannel,
                  _ port: MIDIUniqueID?,
                  _ time: MIDITimeStamp?,
                  _ visit: Visitor) {
        
        noteOnIn˚.setAnyExprs(
            [("num",  Double(num)),
             ("velo", Double(velo)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOptions, visit)
        
        if !visit.type.has(.remote) {
            let noteItem = MidiNoteItem(num, velo, chan, port, time)
            let midiItem = MidiItem(noteOn: noteItem)
            MidiItem.sendItemToPeers(midiItem)
        }
    }
    
    func noteOffIn(_ num: MIDINoteNumber,
                   _ velo: MIDIVelocity,
                   _ chan: MIDIChannel,
                   _ port: MIDIUniqueID?,
                   _ time: MIDITimeStamp?,
                   _ visit: Visitor) {
        
        noteOffIn˚.setAnyExprs(
            [("num",  Double(num)),
             ("velo", Double(velo)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOptions, visit)
        
        if !visit.type.has(.remote) {
            let noteItem = MidiNoteItem(num, velo, chan, port, time)
            let midiItem = MidiItem(noteOff: noteItem)
            MidiItem.sendItemToPeers(midiItem)
        }
    }
    
    func controllerIn(_ cc  : MIDIByte,
                      _ velo: MIDIVelocity,
                      _ chan: MIDIChannel,
                      _ port: MIDIUniqueID?,
                      _ time: MIDITimeStamp?,
                      _ visit: Visitor) {
        
        switch cc {
            
        case 99: nrpnNumMsb = Float(velo) ; return
        case 98: nrpnNumLsb = Float(velo) ; return
        case  6: nrpnValMsb = Float(velo) ; return
        case 38: nrpnValLsb = Float(velo)
            
            if settingNrpn() {
                
                let num  =  (nrpnNumMsb * 128) + nrpnNumLsb
                let velo = ((nrpnValMsb * 128) + nrpnValLsb) / 16383
                
                let icon = String(format: "%.0f:%.3f", num, velo)
                let seq = String(format: "[%.0f_%.0f : %.0f_%.0f]\n",
                                 nrpnNumMsb, nrpnNumLsb, nrpnValMsb, nrpnValLsb)
                MidiLog.log(icon,seq)
                
                nrpnIn˚.setAnyExprs(
                    [("num",  Double(num)),
                     ("val",  Double(velo)),
                     ("chan", Double(chan)),
                     ("port", Double(port ?? 0)),
                     ("time", Double(time ?? 0))],
                    setOptions, visit)
                return
            }
        default: break //clearNrpn()
        }
        
        controllerIn˚.setAnyExprs(
            [("cc",   Double(cc)),
             ("val",  Double(velo)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOptions, visit)
        
        if !visit.type.has(.remote) {
            let item = MidiControllerItem(cc,velo,chan,port,time)
            let midiItem = MidiItem(controller: item)
            MidiItem.sendItemToPeers(midiItem)
        }
    }
    
    func settingNrpn() -> Bool {
        if nrpnNumMsb != -1,
           nrpnNumLsb != -1,
           nrpnValMsb != -1 {
            return true
        }
        return false
    }
    
    func clearNrpn() {
        nrpnNumMsb = -1
        nrpnNumLsb = -1
        nrpnValMsb = -1
        nrpnValLsb = -1
    }
    
    func aftertouchIn(_ num   : MIDINoteNumber,
                      _ val   : MIDIByte,
                      _ chan  : MIDIChannel,
                      _ port  : MIDIUniqueID?,
                      _ time  : MIDITimeStamp?,
                      _ visit : Visitor) {
        
        //let exprs = Express(Flo("afterTouchIn"),)
        
        afterTouchIn˚.setAnyExprs(
            [("num",  Double(num)),
             ("val",  Double(val)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOptions, visit)
        
        if !visit.type.has(.remote) {
            let item = MidiAftertouchItem(num, val,chan,port,time)
            let midiItem = MidiItem(aftertouch: item)
            MidiItem.sendItemToPeers(midiItem)
        }
    }
    
    func aftertouchIn(_ val   : MIDIByte,
                      _ chan  : MIDIChannel,
                      _ port  : MIDIUniqueID?,
                      _ time  : MIDITimeStamp?,
                      _ visit : Visitor) {
        
        afterTouchIn˚.setAnyExprs(
            [("num",  Double(0)),
             ("val",  Double(val)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOptions, visit)
        
        if !visit.type.has(.remote) {
            let item = MidiAftertouchItem(0, val,chan,port,time)
            let midiItem = MidiItem(aftertouch: item)
            MidiItem.sendItemToPeers(midiItem)
        }
    }
    
    func pitchwheelIn(_ val   : MIDIWord,
                      _ chan  : MIDIChannel,
                      _ port  : MIDIUniqueID?,
                      _ time  : MIDITimeStamp?,
                      _ visit : Visitor) {
        
        pitchBendIn˚.setAnyExprs(
            [("val",  Double(val)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOptions, visit)
        
        if !visit.type.has(.remote) {
            let item = MidiPitchbendItem(val,chan,port,time)
            let midiItem = MidiItem(pitchwheel: item)
            MidiItem.sendItemToPeers(midiItem)
        }
    }
    
    func programIn(_ num   : MIDIByte,
                         _ chan  : MIDIChannel,
                         _ port  : MIDIUniqueID?,
                         _ time  : MIDITimeStamp?,
                         _ visit : Visitor) {
        
        programIn˚.setAnyExprs(
            [("num",  Double(num)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOptions, visit)
        
        if !visit.type.has(.remote) {
            let item = MidiProgramItem(num,chan,port,time)
            let midiItem = MidiItem(program: item)
            MidiItem.sendItemToPeers(midiItem)
        }
    }
}
