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

    public init(_ root˚: Flo) {

        self.muMidi = MuMidi(midi, root˚)
        self.audioEngine = AudioEngine()
        Task { @MainActor in
            TouchMidi.muMidi = muMidi
            Peers.shared.addDelegate(self, for: .midiItem)
        }

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

    public func received(data: Data, from: DataFrom) {
        let decoder = JSONDecoder()
        if let item = try? decoder.decode(MidiItem.self, from: data) {
            Task { @MainActor in
                TouchMidi.receiveItem_(item, from: from)
            }
        }
    }
    public func resetItem(_ playItem: PlayItem) {
        let decoder = JSONDecoder()
        let data = playItem.data
        if let item = try? decoder.decode(MidiItem.self, from: data) {
            Task { @MainActor in
                TouchMidi.resetItem(item)
            }
        }
    }
    public func shareItem(_ item: Any) {
    }
    public func playItem(_ item: PlayItem, from: DataFrom) {
        received(data: item.data, from: from)
    }

}
