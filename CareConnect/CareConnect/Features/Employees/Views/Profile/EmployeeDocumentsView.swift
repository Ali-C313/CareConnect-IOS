//
//  EmployeeDocumentsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Liste der PDF-Dokumente mit Hinzufügen und Löschen
struct EmployeeDocumentsView: View {
    @Environment(\.openURL) private var openURL
    let documents: [EmployeeDocument]
    let isUploading: Bool
    let onAdd: () -> Void
    let onDelete: (EmployeeDocument) -> Void

    var body: some View {
        SectionCard {
            HStack {
                Text(tr("Dokumente")).font(.headline)
                Spacer()
                if isUploading {
                    ProgressView()
                } else {
                    Button(action: onAdd) {
                        Label(tr("Hinzufügen"), systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            if documents.isEmpty {
                Text(tr("Noch keine Dokumente vorhanden.")).foregroundColor(.secondary)
            } else {
                ForEach(documents) { document in
                    documentRow(document)
                }
            }
        }
    }

    private func documentRow(_ document: EmployeeDocument) -> some View {
        HStack(spacing: 10) {
            Button {
                if let url = URL(string: document.downloadURL) { openURL(url) }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "doc.richtext.fill")
                        .font(.title)
                        .foregroundColor(.red)
                    VStack(alignment: .leading) {
                        Text(document.fileName).lineLimit(1)
                        Text(tr("Tippen zum Anzeigen"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button(role: .destructive) {
                onDelete(document)
            } label: {
                Image(systemName: "trash")
            }
            .accessibilityLabel(tr("Löschen"))
        }
        .padding(8)
        .background(CCDesign.field, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    EmployeeDocumentsView(documents: [EmployeeDocument(fileName: "Vertrag.pdf")], isUploading: false,
                          onAdd: {}, onDelete: { _ in })
        .padding()
        .screenBackground()
}
