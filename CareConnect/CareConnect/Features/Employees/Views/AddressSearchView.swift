//
//  AddressSearchView.swift
//  CareConnect
//
//  Created by Ali Chehab on 01.11.25.
//

import SwiftUI
import Foundation

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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.accentColor)
                TextField(title, text: $vm.queryFragment)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if !vm.suggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(vm.suggestions, id: \.self) { suggestion in
                            Button {
                                withAnimation {
                                    vm.queryFragment = suggestion
                                    onSelect(suggestion)
                                }
                            } label: {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                    Text(suggestion)
                                        .foregroundColor(.primary)
                                        .font(.body)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(10)
                                .background(Color(.systemGray5).opacity(0.3))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top, 6)
                }
                .frame(maxHeight: 250)
                .scrollIndicators(.hidden)
                .transition(.opacity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.suggestions)
    }
}

#Preview {
    AddressSearchView(onSelect: { value in
        print("Ausgewählte Adresse:", value)
    })
}