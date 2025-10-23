//
//  SearchBarView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Suche…"
    
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
