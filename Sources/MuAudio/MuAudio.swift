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
    let share: Share

    public init(_ root˚: Flo,
                _ share: Share) {

        self.muMidi = MuMidi(midi, root˚, share)
        self.audioEngine = AudioEngine()
        self.share = share
        Task { @MainActor in
            TouchMidi.muMidi = muMidi
        }
        share.peers.addDelegate(self, for: .midiFrame)
    }

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
    public func shareItem(_ item: MidiItem) {
    }
}
