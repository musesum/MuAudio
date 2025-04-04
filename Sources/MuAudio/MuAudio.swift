//
//  MuAudio.swift
//  MuseSky
//
//  created by musesum on 7/22/21.


import Foundation
import AudioKit
import MuPeer
import MuFlo

public class MuAudio: @unchecked Sendable {

    let midi: MuMidi

    let engine = AudioEngine()

    public init(_ root: Flo) {
        self.midi = MuMidi(root: root)
        Peers.shared.delegates["MuAudio"] = self
    }
    deinit { Peers.shared.removeDelegate("MuAudio") }

    public func test() {

        let oscillator = AudioKit.PlaygroundOscillator()
        engine.output = oscillator
        do {
            try engine.start()
            oscillator.start()
            oscillator.frequency = 440
            sleep(2)
            oscillator.stop()
        }
        catch {
            PrintLog("⁉️ \(error)")
        }

    }
}

extension MuAudio: PeersDelegate {

    public func didChange() {
    }

    public func received(data: Data, viaStream: Bool) {
        let decoder = JSONDecoder()
        if let item = try? decoder.decode(MidiItem.self, from: data) {

            midi.remoteMidiItem(item)
        }
    }


}

