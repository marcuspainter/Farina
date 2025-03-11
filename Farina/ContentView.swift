//
//  ContentView.swift
//  Farina
//
//  Created by Marcus Painter on 11/03/2025.
//

// http://pcfarina.eng.unipr.it/Public/Presentations/AES122-Farina.pdf

import Charts
import SwiftUI
import VecLab

struct ContentView: View {
    var sweepLength: Int
    var sweep: RealArray
    var sweepInverse: RealArray
    var magnitudeConvolution: RealArray
    var magnitudeSweep: RealArray
    var magnitudeSweepInverse: RealArray
    var impulse: RealArray
    var xAxis: RealArray
    let startFrequency = 20.0
    let endFrequency = 20000.0
    let sampleRate = 48000.0

    init() {
        tic()
        sweepLength = Int(2.0 ** 12.0)
        sweepLength = 256*4

        // Total duration of the sweep
        let T = Double(sweepLength) / sampleRate
        
        // Time vector
        let t = vector(0 ..< sweepLength) / sampleRate
        let R = log(endFrequency / startFrequency)
        let k = exp(t * R / T)

        // Sweep generation
        sweep = sin((2 * .pi * startFrequency * T / R) * (exp(t * R / T) - 1))
        
        // Time reverse sweep and scale
        sweepInverse = flip(sweep) / k

        // FFT of real signals
        let fftSweep = fftr(sweep)
        let fftSweepInverse = fftr(sweepInverse)

        // Convolution, complex vector multiplication
        let convolution = fftSweep * fftSweepInverse

        // Inverse FFT with real result
        impulse = ifftr(convolution)

        // Shift to center
        impulse = fftshift(impulse)

        // Get magnitudes in dB
        magnitudeConvolution = mag2db(abs(convolution))
        magnitudeSweep = mag2db(abs(fftSweep))
        magnitudeSweepInverse = mag2db(abs(fftSweepInverse))

        // Frequency x axis
        let binFrequency = sampleRate / Double(sweepLength)
        xAxis = vector(0 ..< sweepLength) * binFrequency
        toc()
    }

    var body: some View {
        NavigationStack {
            VStack {
                
                Plot(sweep, sweepInverse)
                    .title("Sweep")
                    .xLabel("Time - samples")
                    .yLabel("Amplitude")
                    .legend("Sweep", "Inverse")
                    .lineWidth(2.0, 2.0)
                    .frame(height: 250)
   
                Plot(x: xAxis, y: magnitudeSweep, magnitudeSweepInverse, magnitudeConvolution, type: .semiLogX)
                    .title("Spectrum")
                    .xLabel("Frequency - Hz")
                    .yLabel("Power - dB")
                    .xLim(20.0, sampleRate / 2.0)
                    .lineWidth(2.0, 2.0, 2.0)
                    .legend("Sweep", "Inverse", "Response")
                    .xTicks([31.0, 62.0, 125.0, 250.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0, 16000.0])
                    .frame(height: 250)
                
                Plot(impulse)
                    .title("Impulse")
                    .xLabel("Time - samples")
                    .yLabel("Amplitude")
                    .lineWidth(2.0)
                    .frame(height: 250)
    
            }
            .padding()
            .navigationBarTitle("Farina", displayMode: .inline)
        }
    }
}

#Preview {
    ContentView()
}
