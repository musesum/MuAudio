// created by musesum on 4/27/25

import SwiftUI
import AVFoundation
import AudioKit
import MuFlo
import MuPeers

public struct MidiNoteItem: Codable, Sendable {

    let num:  MIDINoteNumber
    let velo: MIDIVelocity
    let chan: MIDIChannel
    let port: MIDIUniqueID?
    let time: MIDITimeStamp?

    init (_ num:  MIDINoteNumber,
          _ velo: MIDIVelocity,
          _ chan: MIDIChannel,
          _ port: MIDIUniqueID?,
          _ time: MIDITimeStamp?) {

        self.num  = num
        self.velo = velo
        self.chan = chan
        self.port = port
        self.time = time
    }
}
public struct MidiControllerItem: Codable, Sendable {

    let cc  : MIDIByte
    let velo: MIDIVelocity
    let chan: MIDIChannel
    let port: MIDIUniqueID?
    let time: MIDITimeStamp?

    init (_ cc  : MIDIByte,
          _ velo: MIDIVelocity,
          _ chan: MIDIChannel,
          _ port: MIDIUniqueID?,
          _ time: MIDITimeStamp?) {

        self.cc   = cc
        self.velo = velo
        self.chan = chan
        self.port = port
        self.time = time
    }
}
public struct MidiAftertouchItem: Codable, Sendable {

    let num : MIDINoteNumber
    let val : MIDIByte
    let chan: MIDIChannel
    let port: MIDIUniqueID?
    let time: MIDITimeStamp?

    init (_ num : MIDINoteNumber,
          _ val : MIDIByte,
          _ chan: MIDIChannel,
          _ port: MIDIUniqueID?,
          _ time: MIDITimeStamp?) {

        self.num  = num
        self.val  = val
        self.chan = chan
        self.port = port
        self.time = time
    }
}
public struct MidiPitchbendItem: Codable, Sendable{

    let val : MIDIWord
    let chan: MIDIChannel
    let port: MIDIUniqueID?
    let time: MIDITimeStamp?

    init (_ val : MIDIWord,
          _ chan: MIDIChannel,
          _ port: MIDIUniqueID?,
          _ time: MIDITimeStamp?) {

        self.val  = val
        self.chan = chan
        self.port = port
        self.time = time
    }
}
public struct MidiProgramItem: Codable, Sendable {

    let num : MIDIByte
    let chan: MIDIChannel
    let port: MIDIUniqueID?
    let time: MIDITimeStamp?

    init (_ num : MIDIByte,
          _ chan: MIDIChannel,
          _ port: MIDIUniqueID?,
          _ time: MIDITimeStamp?) {

        self.num  = num
        self.chan = chan
        self.port = port
        self.time = time
    }
}

public enum MidiType: String, CodingKey {
    case noteOn, noteOff, controller, aftertouch, pitchbend, program }

