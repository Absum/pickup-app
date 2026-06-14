//
//  TunerViewModel.swift
//  Maps detected pitch onto the nearest guitar string (or a manually chosen
//  one), with log-space smoothing for a stable readout.
//

import AVFoundation
import Observation
import SwiftUI

@Observable
final class TunerViewModel {
    enum Direction { case flat, inTune, sharp }

    struct Reading {
        let string: GuitarString
        let cents: Double
        let frequency: Double

        var isInTune: Bool { abs(cents) <= 5 }
        var direction: Direction {
            if isInTune { return .inTune }
            return cents < 0 ? .flat : .sharp
        }
    }

    var reading: Reading?
    var isListening = false
    var permissionDenied = false
    /// Target string for manual mode; nil means auto-detect the nearest.
    var manualString: GuitarString?

    private let audio = AudioEngine()
    private var smoothedFrequency: Double = 0
    private var silenceFrames = 0

    init() {
        audio.onResult = { [weak self] in self?.handle($0) }
        loadDemoStateIfNeeded()
    }

    /// DEBUG-only: seed a fixed reading for design QA via the PICKUP_DEMO env var
    /// (format "stringIndex:cents", e.g. "5:0" or "0:-22"). No production effect.
    private func loadDemoStateIfNeeded() {
        #if DEBUG
        guard let demo = ProcessInfo.processInfo.environment["PICKUP_DEMO"] else { return }
        if demo == "listen" {
            // Auto-start the mic for end-to-end testing in the simulator.
            DispatchQueue.main.async { [weak self] in self?.toggle() }
            return
        }
        let parts = demo.split(separator: ":")
        guard parts.count == 2,
              let index = Int(parts[0]), GuitarTuning.standard.indices.contains(index),
              let cents = Double(parts[1]) else { return }
        let string = GuitarTuning.standard[index]
        let frequency = string.frequency * pow(2.0, cents / 1200.0)
        reading = Reading(string: string, cents: cents, frequency: frequency)
        isListening = true
        #endif
    }

    /// The string to highlight in the picker.
    var activeStringID: Int? { reading?.string.id ?? manualString?.id }

    func toggle() { isListening ? stop() : start() }

    /// Tap a string to lock onto it; tap again (same string) to return to auto.
    func selectString(_ string: GuitarString) {
        manualString = (manualString?.id == string.id) ? nil : string
    }

    private func start() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                guard granted else { self.permissionDenied = true; return }
                do {
                    try self.audio.start()
                    self.isListening = true
                } catch {
                    print("Pickup: audio start failed — \(error)")
                }
            }
        }
    }

    private func stop() {
        audio.stop()
        isListening = false
        reading = nil
        smoothedFrequency = 0
    }

    private func handle(_ result: AudioEngine.Result?) {
        guard let result else {
            silenceFrames += 1
            if silenceFrames > 8 {
                reading = nil
                smoothedFrequency = 0
            }
            return
        }
        silenceFrames = 0

        // Smooth in log space so cents stays steady but still responsive.
        smoothedFrequency = smoothedFrequency == 0
            ? result.frequency
            : exp(log(smoothedFrequency) * 0.7 + log(result.frequency) * 0.3)

        let target = manualString ?? GuitarTuning.nearestString(toFrequency: smoothedFrequency).string
        reading = Reading(string: target,
                          cents: GuitarTuning.cents(from: smoothedFrequency, to: target),
                          frequency: smoothedFrequency)
    }
}
