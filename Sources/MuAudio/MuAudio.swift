//
//  MuAudio.swift
//  MuseSky
//
//  created by musesum on 7/22/21.


import Foundation
import AudioKit
import MuPeer
import MuFlo

public class MuAudio {

    public static let shared = MuAudio()
    let engine = AudioEngine()
    init() {
        PeersController.shared.peersDelegates.append(self)
    }
    deinit {
        PeersController.shared.remove(peersDelegate: self)
    }

    public func test() {

        let oscillator = AudioKit.PlaygroundOscillator()
        engine.output = oscillator
        do {
            try engine.start()
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
extension MuAudio: PeersControllerDelegate {

    public func didChange() {
    }

    public func received(data: Data,
                         viaStream: Bool) -> Bool {
        let decoder = JSONDecoder()
        if let item = try? decoder.decode(MidiItem.self, from: data) {
            TouchMidi.remoteItem(item)
            return true
        }
        return false
    }


}

