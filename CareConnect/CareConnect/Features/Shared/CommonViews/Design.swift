//
//  CCDesign.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

enum CCDesign {
    // MARK: - Farben (Color Assets im Asset Catalog anlegen)
    static let background = Color("CC/Background")           // z.B. #F5FAF8 (hell) / #0B1010 (dunkel)
    static let card       = Color("CC/Card")                 // z.B. #FFFFFF / #111416
    static let accent     = Color("CC/Accent")               // #1EAE98 (teal-grün)
    static let info       = Color("CC/Info")                 // systemTeal
    static let danger     = Color("CC/Danger")               // systemRed
    static let textPrimary   = Color("CC/Text/Primary")      // Label-Farbe
    static let textSecondary = Color("CC/Text/Secondary")    // Secondary Label

    // MARK: - Layout
    static let radius: CGFloat = 16
    static let outerSpacing: CGFloat = 16
    static let innerSpacing: CGFloat = 12

    // MARK: - Kartenstil
    static func cardStyle() -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(card)
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}
