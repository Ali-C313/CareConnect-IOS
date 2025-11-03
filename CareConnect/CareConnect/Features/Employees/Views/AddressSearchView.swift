//
//  AddressSearchView.swift
//  CareConnect
//
//  Created by Ali Chehab on 01.11.25.
//

import SwiftUI

struct AddressSearchView: View {
    /// ViewModel
    @StateObject private var vm = AddressSearchViewModel()
    /// Feldtitel
    var title: String = "Adresse"
    /// Ländercode
    var countryCode: String? = "de"
    /// Auswahl-Callback
    var onSelect: (String) -> Void

    /// UI-Inhalt
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(title, text: $vm.query)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .onChange(of: vm.query) { _ in vm.onQueryChanged(countryCode: countryCode) }

            if vm.isLoading { ProgressView().scaleEffect(0.9) }

            if !vm.suggestions.isEmpty {
                List(vm.suggestions) { item in
                    Button {
                        vm.select(item)
                        onSelect(item.formatted)
                    } label: {
                        Text(item.formatted)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 220)
            }

            if let msg = vm.errorMessage {
                Text(msg).foregroundStyle(.red).font(.footnote)
            }
        }
        .animation(.default, value: vm.suggestions)
    }
}


#Preview {
    AddressSearchView(onSelect: { value in
        print("Ausgewählte Adresse:", value)
    })
}
