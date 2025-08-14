//  MuMidiListener.swift
//  created by musesum on 11/4/22.
import Foundation
import AudioKit
import AVFoundation
import MuFlo
import MuPeers

class MuMidiListener: MIDIListener {

    public var midiFlo: MidiFlo
    var midi: MIDI
    init(_ midi: MIDI,
         _ root: Flo,
         _ share: Share) {
        self.midi = midi
        midiFlo = MidiFlo(midi, root, share)
    }

    func noteStr(_ note: MIDINoteNumber) -> String {
        let names = ["C", "D♭", "D", "E♭", "E", "F",
                     "G♭", "G", "A♭", "A", "B♭", "B"]
        let octave = Int(note / 12)
        let note = Int(note % 12)
        return "\(names[note])\(octave)"
    }
    func note(_ channel: MIDIChannel,
              _ note: MIDINoteNumber,
              _ velocity: MIDIVelocity) -> String {

        return "\(channel.digits(2)) \(noteStr(note)): \(velocity)"
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID?,
                            timeStamp: MIDITimeStamp?) {

        MidiLog.log("♪", note(channel, noteNumber, velocity))
        midiFlo.noteOnIn(noteNumber, velocity, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID?,
                             timeStamp: MIDITimeStamp?) {

        MidiLog.log("∅", note(channel, noteNumber, velocity))
        midiFlo.noteOffIn(noteNumber, velocity, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIController(_ cc: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {


        MidiLog.log("🎚", "\(channel.digits(2)) cc_\(cc): \(value)")
        midiFlo.controllerIn(cc, value, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIAftertouch(noteNumber : MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {

        MidiLog.log("􀖓", "\(channel.digits(2)) \(noteStr(noteNumber)) after: \(pressure)")
        midiFlo.aftertouchIn(pressure, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        MidiLog.log("􀖓", "\(channel.digits(2)) after: \(pressure)")
        midiFlo.aftertouchIn(pressure, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        MidiLog.log("􁂩", "\(channel.digits(2)) wheel: \(Int64(pitchWheelValue)-8192)")
        midiFlo.pitchwheelIn(pitchWheelValue, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID?,
                                   timeStamp: MIDITimeStamp?) {
        MidiLog.log("􀣋", "\(program)")
        midiFlo.programIn(program, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID?,
                                   timeStamp: MIDITimeStamp?) {
        MidiLog.log("􀩿", " Midi System \(data)\n")
    }

    func receivedMIDISetupChange() {
        MidiLog.log("􁀘", " Midi Setup change\n")
        midiFlo.midi.openInput()
        midiFlo.midi.openOutput()
    }

    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        MidiLog.log("􀡷", " Midi Property messageID: \(propertyChangeInfo.messageID)\n")
    }

    func receivedMIDINotification(notification: MIDINotification) {
        MidiLog.log("􀑬", " Midi Notification messageID: \(notification.messageID)\n")
    }
}
