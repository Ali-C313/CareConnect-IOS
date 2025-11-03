//
//  PDFPreviewView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    /// PDF-URL
    let url: URL
    /// Dateiname
    let fileName: String
    
    /// UI-Inhalt
    var body: some View {
        VStack {
            if let pdf = PDFDocument(url: url) {
                PDFKitView(document: pdf)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Fehler beim Laden der Datei.")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle(fileName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// PDFKit-Wrapper
struct PDFKitView: UIViewRepresentable {
    /// PDF-Dokument
    let document: PDFDocument
    /// PDFView erstellen
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        return view
    }
    /// PDFView aktualisieren
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
