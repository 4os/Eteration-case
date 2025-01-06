//
//  ThemeManager.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

enum ThemeManager {
    
    // Primary Colors
    static let primaryColor: UIColor = UIColor(hex: "#2A59FE")
    static let secondaryColor: UIColor = UIColor(hex: "#D9D9D9")
    static let alertColor: UIColor = UIColor(hex: "#F90000")
    
    // Background Colors
    static let backgroundColor: UIColor = UIColor.systemBackground
    static let secondaryContainterColor: UIColor = UIColor(hex: "#C4C4C4")
    
    // Text Colors
    static let primaryTextColor: UIColor = UIColor.label
    static let secondaryTextColor: UIColor = UIColor.white

    enum CornerRadius: CGFloat {
        case small = 4.0
        case medium = 8.0
        case large = 16.0
        case extraLarge = 24.0
    }
    
    enum Spacing: CGFloat {
        case xsmall = 4.0
        case small = 8.0
        case medium = 10.0
        case large = 16.0
        case extraLarge = 24.0
    }
}

// MARK: - UIColor Extension
private extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
