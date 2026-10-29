//
//  Double+Format.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Entfernung und Fahrzeit für die Karte
extension Double {
    /// 3400.0 → "3,4 km"
    var kmString: String {
        let km = (self / 100).rounded() / 10
        return "\(km) km".replacingOccurrences(of: ".", with: ",")
    }

    /// Sekunden → "12 min"
    var minutesString: String { "\(Int(ceil(self / 60))) min" }
}
