//
//  CompletionSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Abschließen mit Leistungsnachweis: was wurde gemacht und Unterschrift vom Patienten
struct CompletionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    @State private var signedBy: String
    @State private var strokes: SignatureStrokes = []
    @State private var noSignature = false

    let onConfirm: (_ note: String, _ signature: String, _ signedBy: String) -> Void

    init(patientName: String, onConfirm: @escaping (String, String, String) -> Void) {
        self.onConfirm = onConfirm
        _signedBy = State(initialValue: patientName)
    }

    private var canSave: Bool { !note.isBlank && (noSignature || !strokes.isEmpty) }

    var body: some View {
        NavigationStack {
            Form {
                Section(tr("Was wurde gemacht?")) {
                    TextField(tr("Beschreibung"), text: $note, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section(tr("Unterschrift")) {
                    if !noSignature {
                        TextField(tr("Name"), text: $signedBy)
                        SignaturePad(strokes: $strokes)
                            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        Button(tr("Unterschrift löschen"), role: .destructive) { strokes = [] }
                            .disabled(strokes.isEmpty)
                    }
                    Toggle(tr("Unterschrift nicht möglich"), isOn: $noSignature)
                }
            }
            .navigationTitle(tr("Auftrag abschließen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(tr("Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr("Abschließen")) {
                        onConfirm(note.trimmed,
                                  noSignature ? "" : SignatureCoder.encode(strokes),
                                  noSignature ? "" : signedBy.trimmed)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
        // Sonst geht das Sheet beim Unterschreiben nach unten weg
        .interactiveDismissDisabled()
    }
}

#Preview {
    CompletionSheet(patientName: "Maria Schmidt") { _, _, _ in }
}
