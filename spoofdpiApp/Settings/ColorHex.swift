//
//  ColorHex.swift
//  spoofdpiApp
//
//  Created by Maksim Gritsuk on 04.12.2025.
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        let length = hexSanitized.count
        guard length == 6 || length == 8 else { return nil }

        var rgbValue: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgbValue) else { return nil }

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        if length == 6 {
            red = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8) & 0xFF) / 255.0
            blue = Double(rgbValue & 0xFF) / 255.0
            alpha = 1.0
        } else {
            red = Double((rgbValue >> 24) & 0xFF) / 255.0
            green = Double((rgbValue >> 16) & 0xFF) / 255.0
            blue = Double((rgbValue >> 8) & 0xFF) / 255.0
            alpha = Double(rgbValue & 0xFF) / 255.0
        }

        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    func toHex() -> String? {
        #if os(macOS)
        let nsColor = NSColor(self)
        #elseif os(iOS) || os(watchOS) || os(tvOS)
        let nsColor = UIColor(self)
        #else
        return nil
        #endif

        guard let components = nsColor.cgColor.components,
              components.count >= 3 else { return nil }

        let r = Int((components[0] * 255).rounded())
        let g = Int((components[1] * 255).rounded())
        let b = Int((components[2] * 255).rounded())
        let a = components.count == 4 ? Int((components[3] * 255).rounded()) : 255

        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }
}
