//
//  PDFPreviewView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let url: URL
    let fileName: String
    
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

// Native PDFKit-Einbettung
struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        return view
    }
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
