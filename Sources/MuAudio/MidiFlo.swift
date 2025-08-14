//  MidiFlo.swift
//  created by musesum on 11/4/22.

import Foundation
import AudioKit
import AVFoundation
import MuFlo
import MuPeers

class MidiFlo: @unchecked Sendable {

    let midi: MIDI

    // input
    let noteOnIn˚     : Flo
    let noteOffIn˚    : Flo
    let controllerIn˚ : Flo
    let afterTouchIn˚ : Flo
    let pitchWheelIn˚ : Flo
    let programIn˚    : Flo
    let nrpnIn˚       : Flo

    // output
    var noteOnOut˚     : Flo?
    var noteOffOut˚    : Flo?
    var controllerOut˚ : Flo?
    var afterTouchOut˚ : Flo?
    var pitchWheelOut˚ : Flo?
    var programOut˚    : Flo?
    var nrpnOut˚       : Flo?

    // Non-Registered Parameter Number (fine precision)
    var nrpnNumMsb: Float = -1
    var nrpnNumLsb: Float = -1
    var nrpnValMsb: Float = -1
    var nrpnValLsb: Float = -1
    
    public var setOps: SetOps = .fire

    public var share: Share

    init(_ midi: MIDI,
         _ root: Flo,
         _ share: Share) {

        self.midi  = midi
        self.share = share

        let i = root.bind("midi.input")
        noteOnIn˚     = i.bind("note.on"   )
        noteOffIn˚    = i.bind("note.off"  )
        controllerIn˚ = i.bind("controller")
        afterTouchIn˚ = i.bind("afterTouch")
        pitchWheelIn˚ = i.bind("pitchWheel")
        programIn˚    = i.bind("program"   )
        nrpnIn˚       = i.bind("nrpn"      )

        let o = root.bind("midi.output")
        noteOnOut˚     = o.bind("note.on"   ) { f,v in self.noteOnOut    (f,v) }
        noteOffOut˚    = o.bind("note.off"  ) { f,v in self.noteOffOut   (f,v) }
        controllerOut˚ = o.bind("controller") { f,v in self.controllerOut(f,v) }
        afterTouchOut˚ = o.bind("afterTouch") { f,v in self.aftertouchOut(f,v) }
        pitchWheelOut˚ = o.bind("pitchWheel") { f,v in self.pitchbendOut (f,v) }
        programOut˚    = o.bind("program"   ) { f,v in self.programOut   (f,v) }
        nrpnOut˚       = o.bind("nrpn"      )
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

        #if true  // Roli Lumi
        if let val  = exprs["val",  .tween],
           let chan = exprs["chan", .tween] {

            // this is a hack to send out cc messages as midi note
            // to light up the Roli Lumi Block

            self.midi.sendNoteOnMessage(
                noteNumber: MIDINoteNumber(val),
                velocity: MIDIVelocity(64),
                channel: MIDIChannel(chan))

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.midi.sendNoteOffMessage(
                    noteNumber: MIDINoteNumber(val),
                    channel: MIDIChannel(chan)
                )
            }
        }
        #endif
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
        
        noteOnIn˚.setNameNums(
            [("num",  Double(num)),
             ("velo", Double(velo)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOps, visit)
        
        if !visit.type.has(.remote) {
            _ = MidiItem(.noteOn, .noteOn(MidiNoteItem(num, velo, chan, port, time)), share)
        }
    }
    
    func noteOffIn(_ num: MIDINoteNumber,
                   _ velo: MIDIVelocity,
                   _ chan: MIDIChannel,
                   _ port: MIDIUniqueID?,
                   _ time: MIDITimeStamp?,
                   _ visit: Visitor) {
        
        noteOffIn˚.setNameNums(
            [("num",  Double(num)),
             ("velo", Double(velo)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOps, visit)
        
        if !visit.type.has(.remote) {
            _ = MidiItem(.noteOff, .noteOff(MidiNoteItem(num, velo, chan, port, time)), share)
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
                
                nrpnIn˚.setNameNums(
                    [("num",  Double(num)),
                     ("val",  Double(velo)),
                     ("chan", Double(chan)),
                     ("port", Double(port ?? 0)),
                     ("time", Double(time ?? 0))],
                    setOps, visit)
                return
            }
        default: break //clearNrpn()
        }
        
        controllerIn˚.setNameNums(
            [("cc",   Double(cc)),
             ("val",  Double(velo)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOps, visit)
        
        if !visit.type.has(.remote) {
            _ = MidiItem(.controller, .controller(MidiControllerItem(cc,velo,chan,port,time)), share)
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
        
        afterTouchIn˚.setNameNums(
            [("num",  Double(num)),
             ("val",  Double(val)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOps, visit)
        
        if !visit.type.has(.remote) {
            _ = MidiItem(.aftertouch, .aftertouch(MidiAftertouchItem(num, val,chan,port,time)), share)
        }
    }
    
    func aftertouchIn(_ val   : MIDIByte,
                      _ chan  : MIDIChannel,
                      _ port  : MIDIUniqueID?,
                      _ time  : MIDITimeStamp?,
                      _ visit : Visitor) {
        
        afterTouchIn˚.setNameNums(
            [("num",  Double(0)),
             ("val",  Double(val)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOps, visit)
        
        if !visit.type.has(.remote) {
            _ = MidiItem(.aftertouch, .aftertouch(MidiAftertouchItem(0, val,chan,port,time)), share)
        }
    }
    
    func pitchwheelIn(_ val   : MIDIWord,
                      _ chan  : MIDIChannel,
                      _ port  : MIDIUniqueID?,
                      _ time  : MIDITimeStamp?,
                      _ visit : Visitor) {
        
        pitchWheelIn˚.setNameNums(
            [("val",  Double(val)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOps, visit)
        
        if !visit.type.has(.remote) {
            _ = MidiItem(.pitchbend, .pitchbend(MidiPitchbendItem(val,chan,port,time)), share)
        }
    }
    
    func programIn(_ num   : MIDIByte,
                   _ chan  : MIDIChannel,
                   _ port  : MIDIUniqueID?,
                   _ time  : MIDITimeStamp?,
                   _ visit : Visitor) {
        
        programIn˚.setNameNums(
            [("num",  Double(num)),
             ("chan", Double(chan)),
             ("port", Double(port ?? 0)),
             ("time", Double(time ?? 0))],
            setOps, visit)
        
        if !visit.type.has(.remote) {
            _ = MidiItem(.program, .program(MidiProgramItem(num, chan, port, time)), share)
        }
    }
}
