// MARK: - TimeDuck · SoundEngine.swift
// 8-bit chiptune synthesis and procedural duck quacks.
// Architecture: Persistent, single AVAudioEngine with AVAudioPlayerNode and
// pre-synthesized / scheduled AVAudioPCMBuffer audio.
// Buffers are synthesized outside realtime callbacks and the engine is reused across sounds.

import Foundation
import AVFoundation

final class SoundEngine {
    var enabled: Bool {
        get { UserDefaults.standard.object(forKey: "td.sound") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "td.sound") }
    }

    var musicEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "td.music") as? Bool ?? true }
        set {
            UserDefaults.standard.set(newValue, forKey: "td.music")
            if Thread.isMainThread {
                if newValue { startMusic() } else { stopMusic() }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if newValue { self.startMusic() } else { self.stopMusic() }
                }
            }
        }
    }

    enum Wave {
        case sine
        case square
        case triangle
        case sawtooth
    }

    private let sampleRate: Double = 44100.0
    private let audioFormat: AVAudioFormat
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var isEngineSetup = false
    private let audioQueue = DispatchQueue(label: "com.oxalpha.timeduck.audio", qos: .userInitiated)

    // Music Player & Volume
    private var musicPlayer: AVAudioPlayer?
    private let defaultMusicVolume: Float = 0.55

    // Pre-cached buffers avoid repeat synthesis for frequent UI actions.
    private var cachedClickBuffer: AVAudioPCMBuffer?
    private var cachedBlipBuffer: AVAudioPCMBuffer?
    private var cachedQuackBuffer: AVAudioPCMBuffer?

    init() {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            fatalError("Failed to create standard AVAudioFormat")
        }
        self.audioFormat = format
        setupEngine()
        precacheCommonBuffers()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEngineConfigurationChange),
            name: .AVAudioEngineConfigurationChange,
            object: engine
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        musicPlayer?.stop()
        engine.stop()
    }

    @objc private func handleEngineConfigurationChange(_ notification: Notification) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            self.setupEngine()
        }
    }

    private func setupEngine() {
        do {
            if playerNode.engine == nil {
                engine.attach(playerNode)
            }
            engine.connect(playerNode, to: engine.mainMixerNode, fromBus: 0, toBus: 0, format: audioFormat)
            engine.mainMixerNode.outputVolume = 1.0
            if !engine.isRunning {
                try engine.start()
            }
            isEngineSetup = true
        } catch {
            isEngineSetup = false
        }
    }

    private func ensureEngineRunning() {
        if !engine.isRunning {
            try? engine.start()
        }
        if !playerNode.isPlaying {
            playerNode.play(at: nil)
        }
    }

    private func precacheCommonBuffers() {
        cachedClickBuffer = synthesizeToneBuffer(freq: 2200, dur: 0.012, vol: 0.08, type: .triangle)
        cachedBlipBuffer = synthesizeToneBuffer(freq: 880, dur: 0.04, vol: 0.10, type: .sine)
        cachedQuackBuffer = synthesizeQuackBuffer()
    }

    // MARK: - PCM Synthesis

    private func synthesizeToneBuffer(freq: Double, dur: Double, vol: Double, type: Wave) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * dur)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount),
              let channelData = buffer.floatChannelData else {
            return nil
        }
        buffer.frameLength = frameCount
        let data = channelData[0]
        let n = Int(frameCount)
        let fadeFrames = min(Int(sampleRate * 0.002), n / 4) // 2ms click-free attack/release

        for i in 0..<n {
            let t = Double(i) / sampleRate
            let phase = (t * freq).truncatingRemainder(dividingBy: 1.0)
            var s: Float
            switch type {
            case .sine:
                s = Float(sin(2.0 * Double.pi * phase))
            case .square:
                s = Float(phase < 0.5 ? 0.5 : -0.5)
            case .triangle:
                s = Float(phase < 0.5 ? (4.0 * phase - 1.0) : (3.0 - 4.0 * phase))
            case .sawtooth:
                s = Float(2.0 * phase - 1.0)
            }

            // Click-free edge envelope
            var env = 1.0
            if i < fadeFrames {
                env = Double(i) / Double(fadeFrames)
            } else if i >= n - fadeFrames {
                env = Double(n - 1 - i) / Double(fadeFrames)
            }

            data[i] = Float(Double(s) * vol * env)
        }

        return buffer
    }

    private func synthesizeQuackBuffer(pitch: Double = 1.0) -> AVAudioPCMBuffer? {
        let dur = 0.16 / pitch
        let frameCount = AVAudioFrameCount(sampleRate * dur)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount),
              let channelData = buffer.floatChannelData else {
            return nil
        }
        buffer.frameLength = frameCount
        let data = channelData[0]
        let n = Int(frameCount)

        var phase1 = 0.0
        var phase2 = 0.0

        for i in 0..<n {
            let progress = Double(i) / Double(n)
            let f1 = (580.0 - progress * 240.0) * pitch   // Pitch drop sweep
            let f2 = (820.0 - progress * 300.0) * pitch   // Nasal formant resonance
            phase1 = (phase1 + f1 / sampleRate).truncatingRemainder(dividingBy: 1.0)
            phase2 = (phase2 + f2 / sampleRate).truncatingRemainder(dividingBy: 1.0)

            let env = sin(progress * Double.pi) // Smooth bell envelope
            let saw1 = 2.0 * phase1 - 1.0
            let sq2 = phase2 < 0.5 ? 0.3 : -0.3
            let sample = (saw1 * 0.6 + sq2 * 0.4) * env * 0.22

            data[i] = Float(sample)
        }

        return buffer
    }

    private func playBuffer(_ buffer: AVAudioPCMBuffer) {
        guard enabled else { return }
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            self.ensureEngineRunning()
            self.playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        }
    }

    // MARK: - Public Sound API

    func tone(freq: Double, dur: Double, vol: Double = 0.16, type: Wave = .sine) {
        guard enabled else { return }
        if let buf = synthesizeToneBuffer(freq: freq, dur: dur, vol: vol, type: type) {
            playBuffer(buf)
        }
    }

    func click() {
        guard enabled else { return }
        if let buf = cachedClickBuffer {
            playBuffer(buf)
        } else {
            tone(freq: 2200, dur: 0.012, vol: 0.08, type: .triangle)
        }
    }

    func blip() {
        guard enabled else { return }
        if let buf = cachedBlipBuffer {
            playBuffer(buf)
        } else {
            tone(freq: 880, dur: 0.04, vol: 0.10, type: .sine)
        }
    }

    func tick(urgency: Double) {
        guard enabled else { return }
        let freq = urgency > 0.7 ? 1400.0 : 990.0
        let vol = 0.08 + 0.06 * urgency
        tone(freq: freq, dur: 0.025, vol: vol, type: .square)
    }

    func quack(pitch: Double = 1.0) {
        guard enabled else { return }
        if pitch == 1.0, let buf = cachedQuackBuffer {
            playBuffer(buf)
        } else if let buf = synthesizeQuackBuffer(pitch: pitch) {
            playBuffer(buf)
        }
    }

    func happyChirp() {
        guard enabled else { return }
        let notes: [(Double, Double)] = [
            (660.0, 0.05),
            (990.0, 0.08)
        ]
        var delay = 0.0
        for (freq, len) in notes {
            audioQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self, self.enabled else { return }
                self.tone(freq: freq, dur: len, vol: 0.14, type: .sine)
            }
            delay += len * 0.9
        }
    }

    func tinySigh() {
        guard enabled else { return }
        tone(freq: 330.0, dur: 0.18, vol: 0.06, type: .triangle)
    }

    func victoryFanfare() {
        guard enabled else { return }
        duckMusic(for: 2.0)
        let notes: [(Double, Double)] = [
            (523.25, 0.09), // C5
            (659.25, 0.09), // E5
            (783.99, 0.12), // G5
            (1046.50, 0.32) // C6
        ]
        var delay = 0.0
        for (freq, len) in notes {
            audioQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self, self.enabled else { return }
                self.tone(freq: freq, dur: len, vol: 0.20, type: .triangle)
            }
            delay += len * 0.85
        }
    }

    // MARK: - Theme Music System

    private func resolveThemeURL() -> URL? {
        // 1. Canonical App Bundle Location: Contents/Resources/Audio/TimeDuckTheme.m4a
        if let url = Bundle.main.url(forResource: "TimeDuckTheme", withExtension: "m4a", subdirectory: "Audio") {
            return url
        }
        // 2. Development / CLI / Test fallback
        let localPath = "Resources/Audio/TimeDuckTheme.m4a"
        if FileManager.default.fileExists(atPath: localPath) {
            return URL(fileURLWithPath: localPath)
        }
        return nil
    }

    func startMusic() {
        guard musicEnabled else { return }
        if let player = musicPlayer, player.isPlaying { return }
        if musicPlayer == nil {
            guard let url = resolveThemeURL() else {
                #if DEBUG
                print("[TimeDuck SoundEngine] Theme music resource not found at canonical location: Audio/TimeDuckTheme.m4a")
                #endif
                return
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = defaultMusicVolume
                player.prepareToPlay()
                self.musicPlayer = player
            } catch {
                #if DEBUG
                print("[TimeDuck SoundEngine] Failed to initialize AVAudioPlayer: \(error)")
                #endif
                self.musicPlayer = nil
                return
            }
        }
        musicPlayer?.volume = defaultMusicVolume
        let started = musicPlayer?.play() ?? false
        #if DEBUG
        if !started {
            print("[TimeDuck SoundEngine] AVAudioPlayer.play() returned false.")
        }
        #endif
    }

    func stopMusic() {
        musicPlayer?.pause()
    }

    func duckMusic(for duration: TimeInterval = 1.8) {
        guard let player = musicPlayer, player.isPlaying else { return }
        player.volume = defaultMusicVolume * 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self, let player = self.musicPlayer, self.musicEnabled else { return }
            player.volume = self.defaultMusicVolume
        }
    }
}
