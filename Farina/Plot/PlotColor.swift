//
//  PlotColor.swift
//  Farina
//
//  Created by Marcus Painter on 11/03/2025.
//

import SwiftUI

enum PlotColor {
    static let deepBlue = Color(red: 0.0000, green: 0.4470, blue: 0.7410) // deepBlue
    static let burntOrange = Color(red: 0.8500, green: 0.3250, blue: 0.0980) // burntOrange
    static let goldenYellow = Color(red: 0.9290, green: 0.6940, blue: 0.1250) // goldenYellow
    static let purpleViolet = Color(red: 0.4940, green: 0.1840, blue: 0.5560) // purpleViolet
    static let freshGreen = Color(red: 0.4660, green: 0.6740, blue: 0.1880) // freshGreen
    static let skyBlue = Color(red: 0.3010, green: 0.7450, blue: 0.9330) // skyBlue
    static let crimsonRed = Color(red: 0.6350, green: 0.0780, blue: 0.1840) // crimsonRed

    // Function to return color based on MATLAB letter string
    static func color(from letter: String) -> Color? {
        switch letter.lowercased() {
        case "b":
            return deepBlue
        case "r":
            return burntOrange
        case "y":
            return goldenYellow
        case "m":
            return purpleViolet
        case "g":
            return freshGreen
        case "c":
            return skyBlue
        case "k": // Usually black in MATLAB's color cycle
            return Color.black
        default:
            return nil // Return nil if an invalid string is provided
        }
    }
}
