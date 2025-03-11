//
//  View+if.swift
//  Farina
//
//  Created by Marcus Painter on 11/03/2025.
//

import SwiftUI

// Helper extension
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func ifLet<T, Content: View>(_ optional: T?, @ViewBuilder transform: (Self, T) -> Content) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }
}
