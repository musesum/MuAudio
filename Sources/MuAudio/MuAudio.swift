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
    let audioEngine: AudioEngine

    public init(_ root˚: Flo) {
        self.midi = MuMidi(root: root˚)
        self.audioEngine = AudioEngine()
        Peers.shared.delegates["MuAudio"] = self
    }
    deinit {
        Peers.shared.removeDelegate("MuAudio") 
    }

    public func test() {

        let oscillator = AudioKit.PlaygroundOscillator()
        audioEngine.output = oscillator
        do {
            try audioEngine.start()
            oscillator.start()
            oscillator.frequency = 440
            sleep(4)
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
            TouchMidi.remoteItem(item)
        }
    }


}

