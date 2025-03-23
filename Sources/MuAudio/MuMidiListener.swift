//  MuMidiListener.swift
//  created by musesum on 11/4/22.


import Foundation
import AudioKit
import AVFoundation
import MuFlo

class MuMidiListener: MIDIListener {

    public var midiFlo: MidiFlo

    init(_ root: Flo) {
        midiFlo = MidiFlo(root)
    }

    func note(_ note: MIDINoteNumber,
              _ velocity: MIDIVelocity) -> String {

        let names = ["C", "D♭", "D", "E♭", "E", "F",
                     "G♭", "G", "A♭", "A", "B♭", "B"]
        let octave = Int(note / 12)
        let note = Int(note % 12)
        let name = names[note]
        return "\(name)\(octave):\(velocity)"
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID?,
                            timeStamp: MIDITimeStamp?) {

        MidiLog.log("♪", note(noteNumber, velocity))
        midiFlo.noteOnIn(noteNumber, velocity, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID?,
                             timeStamp: MIDITimeStamp?) {

        MidiLog.log("∅", note(noteNumber, velocity))
        midiFlo.noteOffIn(noteNumber, velocity, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIController(_ cc: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {


        let icon = MidiLog.nextIcon("🎚\(cc) =")
        MidiLog.log(icon, " \(value)")
        midiFlo.controllerIn(cc, value, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {

        MidiLog.log("􀖓", note(noteNumber, pressure))
        midiFlo.aftertouchIn(noteNumber, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        MidiLog.log("􀖓", "\(channel):\(pressure)")
        midiFlo.aftertouchIn(pressure, channel, portID, timeStamp, Visitor(0, .midi))
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        let icon = MidiLog.nextIcon("􁂩")
        MidiLog.log(icon, "\(channel):\(Int64(pitchWheelValue)-8192)")
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
        MIDI.sharedInstance.openInput()
        MIDI.sharedInstance.openOutput()
    }

    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        MidiLog.log("􀡷", " Midi Property messageID: \(propertyChangeInfo.messageID)\n")
    }

    func receivedMIDINotification(notification: MIDINotification) {
        MidiLog.log("􀑬", " Midi Notification messageID: \(notification.messageID)\n")
    }
}
