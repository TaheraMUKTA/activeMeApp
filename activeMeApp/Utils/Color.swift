//
//  Color.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 18/03/2025.
//

import Foundation
import SwiftUI

extension Color {
    // Converts a `Color` to a hexadecimal string
    func toHexString() -> String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    // Initializes a `Color` from a hexadecimal string
    init(hex: String) {
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") { scanner.currentIndex = scanner.string.index(after: scanner.currentIndex) }
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
