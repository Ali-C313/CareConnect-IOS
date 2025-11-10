//
//  MapPlaceholderView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation

struct MapPlaceholderView: View {
    /// UI-Inhalt
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue.opacity(0.2))
            .overlay(
                VStack(spacing: 6) {
                    Image(systemName: "map").font(.title)
                    Text("Karte – Platzhalter").font(.footnote).foregroundColor(.white.opacity(0.9))
                }
            )
            .frame(height: 220)
            .padding(.horizontal)
    }
}
#Preview {
    MapPlaceholderView()
}