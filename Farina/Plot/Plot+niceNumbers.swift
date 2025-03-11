//
//  Plot+niceNumbers.swift
//  Farina
//
//  Created by Marcus Painter on 11/03/2025.
//

import Foundation

extension Plot {
    static func niceNumbers(minValue: Double, maxValue: Double, maxTicks: Int = 10) -> [Double] {
        guard minValue < maxValue else { return [] }

        let range = maxValue - minValue
        let roughTickSize = range / Double(maxTicks)

        let magnitude = pow(10.0, floor(log10(roughTickSize))) // Order of magnitude
        let normalizedTickSize = roughTickSize / magnitude

        let niceTickSize: Double
        if normalizedTickSize < 1.5 {
            niceTickSize = 1.0 * magnitude
        } else if normalizedTickSize < 3.0 {
            niceTickSize = 2.0 * magnitude
        } else if normalizedTickSize < 7.0 {
            niceTickSize = 5.0 * magnitude
        } else {
            niceTickSize = 10.0 * magnitude
        }

        let firstTick = ceil(minValue / niceTickSize) * niceTickSize
        let lastTick = floor(maxValue / niceTickSize) * niceTickSize

        var ticks: [Double] = []
        var tick = firstTick
        while tick <= lastTick {
            ticks.append(tick)
            tick += niceTickSize
        }

        return ticks
    }
}
