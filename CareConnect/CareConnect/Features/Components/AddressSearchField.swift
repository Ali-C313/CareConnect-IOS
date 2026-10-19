//
//  AddressSearchField.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Textfeld mit Adressvorschlägen darunter, schreibt die Adresse in das Binding
struct AddressSearchField: View {
    @Binding var address: String
    var title: String = tr("Adresse")

    @State private var search = AddressSearchViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $search.queryFragment)
                .textContentType(.fullStreetAddress)

            ForEach(search.suggestions, id: \.self) { suggestion in
                Button {
                    search.select(suggestion)
                    address = suggestion
                } label: {
                    Label(suggestion, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(CCDesign.textPrimary)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
        }
        .onAppear { search.prefill(address) }
        .onChange(of: search.queryFragment) { _, newValue in
            address = newValue
        }
    }
}

#Preview {
    Form { AddressSearchField(address: .constant("Hauptstraße 1")) }
}
