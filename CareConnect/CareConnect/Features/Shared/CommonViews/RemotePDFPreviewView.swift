import SwiftUI
import Foundation
import PDFKit

struct RemotePDFPreviewView: View {
    /// PDF-URL
    let urlString: String
    /// Dateiname
    let fileName: String
    /// Lokale Datei
    @State private var localURL: URL?
    /// Ladezustand
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Lade PDF …")
                } else if let localURL,
                          let pdfDoc = PDFDocument(url: localURL) {
                    PDFKitRepresentable(document: pdfDoc).ignoresSafeArea()
                } else {
                    Text("PDF konnte nicht angezeigt werden.").foregroundColor(.red)
                }
            }
            .navigationTitle(fileName)
            .navigationBarTitleDisplayMode(.inline)
            .task { await downloadIfNeeded() }
        }
    }

    /// PDF laden
    private func downloadIfNeeded() async {
        guard let remote = URL(string: urlString) else { isLoading = false; return }
        do {
            let (data, _) = try await URLSession.shared.data(from: remote)
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
            try data.write(to: tmp)
            self.localURL = tmp
        } catch {
            print("⚠️ PDF Download fehlgeschlagen:", error.localizedDescription)
        }
        isLoading = false
    }
}