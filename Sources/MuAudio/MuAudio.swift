//  MuAudio.swift
//  created by musesum on 7/22/21.

import Foundation
import AudioKit
import MuPeers
import MuFlo

public class MuAudio: @unchecked Sendable {

    let midi = MIDI()
    let muMidi: MuMidi
    let audioEngine: AudioEngine
    let peers: Peers

    public init(_ root˚: Flo,
                _ peers: Peers) {

        self.muMidi = MuMidi(midi, root˚, peers)
        self.audioEngine = AudioEngine()
        self.peers = peers
        peers.setDelegate(self, for: .midiFrame)
    }
    //..... deinit { peers.removeDelegate(self)  }

    public func testAudio() {

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

    public func received(data: Data) {
        let decoder = JSONDecoder()
        if let item = try? decoder.decode(MidiItem.self, from: data) {
            Task {
                await TouchMidi.remoteItem(item)
            }
        }
    }
}
