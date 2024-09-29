//
//  CustomColor.swift
//  Banquemisr.challenge05
//
//  Created by ios on 29/09/2024.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)

        let red, green, blue, alpha: CGFloat

        switch hexFormatted.count {
        case 3: // RGB (12-bit)
            red = CGFloat((rgb >> 8) & 0xF) / 15.0
            green = CGFloat((rgb >> 4) & 0xF) / 15.0
            blue = CGFloat(rgb & 0xF) / 15.0
            alpha = 1.0
        case 6: // RGB (24-bit)
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
            alpha = 1.0
        case 8: // ARGB (32-bit)
            red = CGFloat((rgb >> 24) & 0xFF) / 255.0
            green = CGFloat((rgb >> 16) & 0xFF) / 255.0
            blue = CGFloat((rgb >> 8) & 0xFF) / 255.0
            alpha = CGFloat(rgb & 0xFF) / 255.0
        default:
            return nil
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
