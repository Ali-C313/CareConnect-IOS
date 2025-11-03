//
//  EmployeeDocumentsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

struct EmployeeDocumentsView: View {
    /// Profil-ViewModel
    @EnvironmentObject var vm: EmployeeProfileViewModel
    /// Importanzeige
    @Binding var showImporter: Bool
    /// Mitarbeiter-ID
    let employeeId: String

    /// UI-Inhalt
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Dokumente")
                    .font(.headline)
                    .foregroundColor(CCDesign.textPrimary)
                Spacer()
                Button {
                    showImporter = true
                } label: {
                    Label("Hinzufügen", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }

            if vm.documents.isEmpty {
                Text("Noch keine Dokumente vorhanden.")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 12)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(vm.documents) { doc in
                        Button {
                            vm.showingPDF = doc
                        } label: {
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.12))
                                    .frame(width: 54, height: 54)
                                    .overlay(
                                        Image(systemName: "doc.richtext.fill")
                                            .font(.title3)
                                            .foregroundColor(.white.opacity(0.9))
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(doc.fileName)
                                        .foregroundColor(CCDesign.textPrimary)
                                        .lineLimit(1)
                                    Text("Tippen zum Anzeigen")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(CCDesign.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await vm.deleteDocument(doc, employeeId: employeeId) }
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(CCDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.separator).opacity(0.25),
                radius: 3, x: 0, y: 2)
    }
}
