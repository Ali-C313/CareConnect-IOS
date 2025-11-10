import SwiftUI
import Foundation
import PDFKit

struct PDFKitRepresentable: UIViewRepresentable {
    /// PDF-Dokument
    let document: PDFDocument
    /// Erstellt PDFView
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.document = document
        v.autoScales = true
        return v
    }
    /// Aktualisiert View
    func updateUIView(_ uiView: PDFView, context: Context) {}
}