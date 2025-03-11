//
//  PlotData.swift
//  Farina
//
//  Created by Marcus Painter on 11/03/2025.
//

import SwiftUI

struct PlotData: Identifiable, Hashable {
    let id = UUID().uuidString

    // Data
    var x: [Double] = []
    var y: [Double] = []

    // Style
    var lineWidth: Double = 1.0
    var color: Color = .blue
    var symbol: PlotMarker = .circle
    var symbolSize: Double = 9
    var legend: String = ""
}
