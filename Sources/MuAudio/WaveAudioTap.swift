//  WaveAudioTap.swift
//  created for the WinSky Waves port (Port/B3.waves.notes.md §6, Port/Stubs.md gaps 1–2).
//
//  LIVE mic tap (2026-07-11) driven by the `mic.input(xy)` menu leaf
//  (<> sky.mic.input): y = volume (0 turns the mic OFF — engine stopped, mic
//  hardware released), x = band-pass sweep. Publishes a signed time-domain
//  sample window (`mag`, WinSky mag(s) semantics) and FFT magnitude bins
//  (`fft`) for the Waves scatter kernel (`cell.wave.metal` buffer(1)/buffer(2)).
//
//  Chain: engine.input (mic) → BandPassFilter → gain Mixer(volume: y) →
//  zero-volume output Mixer so nothing echoes to the speaker. Taps: raw
//  samples on gainMixer, FFT on bandPass — one AVAudio tap per node/bus
//  (BaseTap.start() removes any existing tap on its node, so same-node
//  sibling taps displace each other).
//  Base AudioKit only — Fader lives in AudioKitEX, so Mixer.volume carries
//  both the gain and the output mute (no new package dependency).
//
//  Empty buffers (count 0) keep the kernel's silent-zero contract: mag()/fft()
//  read 0.0 whenever the mic is off.

import Foundation
import AudioKit
import MuFlo // PrintLog
#if os(iOS)
import AVFAudio
#endif

public final class WaveAudioTap: @unchecked Sendable {

    /// tap callbacks arrive on the main queue; WaveNode reads from the render
    /// thread — a lock guards the published copies
    private let lock = NSLock()
    private var _mag: [Float] = []
    private var _fft: [Float] = []

    /// lifecycle (engine/taps/session) is serialized here — update() arrives
    /// from .user, .remote, and archive .bind visit paths; the data `lock`
    /// stays separate so tap callbacks never contend with teardown
    private let lifecycleQueue = DispatchQueue(label: "WaveAudioTap.lifecycle")
    /// mic denied or engine failed: latch off until a volume-0 crossing resets
    private var deniedLatch = false

    /// signed time-domain sample window (uploaded to waveKernel buffer(1); count 0 = silent)
    public var mag: [Float] { lock.lock(); defer { lock.unlock() }; return _mag }
    /// FFT magnitude bins (uploaded to waveKernel buffer(2); count 0 = silent)
    public var fft: [Float] { lock.lock(); defer { lock.unlock() }; return _fft }

    private var engine: AudioEngine?
    private var bandPass: BandPassFilter?
    private var gainMixer: Mixer?
    private var muteMixer: Mixer?
    private var rawTap: RawDataTap?
    private var fftTap: FFTTap?
    private var running = false

    /// diagnostic counters — logged every 30th callback to trace whether
    /// taps deliver at all and whether samples are nonzero
    private var rawCount = 0
    private var fftCount = 0

    public init() { }

    /// `mic.input` leaf state: y volume gates the mic, x sweeps the band-pass.
    /// Idempotent — safe for .user, .remote, and archive .bind visits alike.
    public func update(volume: Float, bandNorm: Float) {
        lifecycleQueue.async { [weak self] in
            guard let self else { return }
            if volume <= 0 {
                self.deniedLatch = false // volume-0 crossing re-arms a retry
                self.stopNow()
            } else {
                if !self.running, !self.deniedLatch { self.startNow() }
                self.gainMixer?.volume = volume
                self.bandPass?.centerFrequency = Self.centerFrequency(bandNorm)
            }
        }
    }

    /// log sweep: x -1…1 → 20 Hz … 22 kHz (x=0 ≈ 660 Hz)
    static func centerFrequency(_ norm: Float) -> AUValue {
        let octaves = AUValue(10.1)
        return 20 * pow(2, (AUValue(norm) + 1) * 0.5 * octaves)
    }

    public func start() { lifecycleQueue.async { [weak self] in self?.startNow() } }
    public func stop()  { lifecycleQueue.async { [weak self] in self?.stopNow() } }

    private func startNow() {
        guard !running else { return }
        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            PrintLog("⁉️ WaveAudioTap session \(error)")
            deniedLatch = true // re-armed by a volume-0 crossing
            return
        }
        #endif
        let engine = AudioEngine()
        guard let input = engine.input else {
            PrintLog("⁉️ WaveAudioTap no engine.input (mic permission?)")
            deniedLatch = true // re-armed by a volume-0 crossing
            return
        }
        let bandPass = BandPassFilter(input)
        let gainMixer = Mixer(bandPass)
        let muteMixer = Mixer(gainMixer)
        muteMixer.volume = 0 // analysis only — never echo the mic to the speaker
        engine.output = muteMixer

        // WinSky mag(s) reads signed time-domain samples across the current
        // buffer, so the source is RawDataTap, post-gain (y volume scales
        // the waveform); 512 samples = 2KB, within WaveNode's 4KB
        // encoder.setBytes inline limit
        let rawTap = RawDataTap(gainMixer, bufferSize: 512) { [weak self] samples in
            guard let self else { return }
            self.lock.lock()
            self._mag = samples
            self.lock.unlock()
            self.rawCount += 1
            if self.rawCount % 30 == 1 {
                let peak = samples.map(abs).max() ?? 0
                DebugLog { P("🎙️ raw #\(self.rawCount) n:\(samples.count) peak:\(peak)") }
            }
        }
        // on bandPass, NOT gainMixer: one AVAudio tap per node/bus — the FFT
        // is normalized to its per-buffer max, so pre-gain placement is
        // output-identical. bufferSize MUST be 2 × bin count: with
        // fftValidBinCount set, FFTTap.performFFT sizes transferBuffer from
        // the bin count (bufferSizePOT = 1024 floats) but vDSP_vmul writes
        // frameLength (= bufferSize) floats into it — the default 4096
        // overruns the allocation by 12KB per callback, corrupting the heap
        // (manifested as EXC_BAD_ACCESS in the Metal encoder). 512 bins =
        // 2KB also satisfies WaveNode's 4KB encoder.setBytes inline limit.
        let fftTap = FFTTap(bandPass,
                            bufferSize: 1024,
                            fftValidBinCount: .fiveHundredAndTwelve) { [weak self] bins in
            guard let self else { return }
            self.lock.lock()
            self._fft = bins
            self.lock.unlock()
            self.fftCount += 1
            if self.fftCount % 30 == 1 {
                let peak = bins.max() ?? 0
                DebugLog { P("🎙️ fft #\(self.fftCount) n:\(bins.count) peak:\(peak)") }
            }
        }
        do {
            try engine.start()
        } catch {
            PrintLog("⁉️ WaveAudioTap engine \(error)")
            deniedLatch = true // re-armed by a volume-0 crossing
            return
        }
        rawTap.start()
        fftTap.start()
        DebugLog { P("🎙️ WaveAudioTap started; taps installed") }

        self.engine = engine
        self.bandPass = bandPass
        self.gainMixer = gainMixer
        self.muteMixer = muteMixer
        self.rawTap = rawTap
        self.fftTap = fftTap
        running = true
    }

    private func stopNow() {
        guard running || engine != nil else {
            clearBuffers()
            return
        }
        rawTap?.stop()
        fftTap?.stop()
        engine?.stop()
        rawTap = nil
        fftTap = nil
        gainMixer = nil
        muteMixer = nil
        bandPass = nil
        engine = nil
        running = false
        clearBuffers()
        #if os(iOS)
        // release the session so the mic privacy indicator drops with the engine
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    private func clearBuffers() {
        lock.lock()
        _mag = []
        _fft = []
        lock.unlock()
    }
}
