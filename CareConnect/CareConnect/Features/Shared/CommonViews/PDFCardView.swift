//
//  PDFCardView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation
import PDFKit

struct PDFCardView: View {
    
    /// PDF-Dateiname
    var fileName: String
    /// Vorschau anzeigen
    @State private var showPreview = false
    /// Lokale PDF-URL
    @State private var localURL: URL? = nil
    
    /// UI-Inhalt
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.12))
                .overlay(
                    VStack {
                        Image(systemName: "doc.richtext.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.9))
                        Text("PDF")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                )
                .frame(height: 80)
            
            Text(fileName)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.white)
        }
        .padding(8)
        .frame(width: 160)
        .onTapGesture {
            openLocalPDF()
        }
        .sheet(isPresented: $showPreview) {
            if let url = localURL {
                NavigationStack {
                    PDFPreviewView(url: url, fileName: fileName)
                }
            } else {
                Text("PDF nicht gefunden.")
            }
        }
    }
    
    /// PDF öffnen
    private func openLocalPDF() {
        // Beispiel: Datei "BeispielPDF.pdf" im Bundle
        let nameWithoutExtension = fileName.replacingOccurrences(of: ".pdf", with: "")
        if let url = Bundle.main.url(forResource: nameWithoutExtension, withExtension: "pdf") {
            localURL = url
            showPreview = true
        } else {
            print("⚠️ PDF nicht im Bundle gefunden:", fileName)
        }
    }
}

#Preview {
    PDFCardView(fileName: "Beispiel.pdf")
}