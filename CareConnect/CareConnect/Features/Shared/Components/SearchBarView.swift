//
//  SearchBarView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct SearchBarView: View {
    /// Suchtext
    @Binding var text: String
    /// Platzhaltertext
    var placeholder: String = "Suche…"
    
    /// UI-Inhalt
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
    }
}
