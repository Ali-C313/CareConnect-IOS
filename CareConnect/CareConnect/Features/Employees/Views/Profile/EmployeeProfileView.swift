//
//  EmployeeProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import MapKit
import PDFKit
import QuickLook

struct EmployeeProfileView: View {
    /// Mitarbeiter-ID
    let employeeId: String
    /// Profil-ViewModel
    @StateObject private var vm = EmployeeProfileViewModel()
    /// Importanzeige
    @State private var showImporter = false

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        EmployeeProfileHeaderView()
                        EmployeeWorkScheduleView()
                        EmployeeDocumentsView(showImporter: $showImporter, employeeId: employeeId)
                    }
                    .padding()
                }
                .overlay(alignment: .top) {
                    if vm.isLoading {
                        ProgressView("Lade …")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Mitarbeiter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showImporter = true } label: {
                        Label("Dokument hinzufügen", systemImage: "doc.badge.plus")
                    }
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        Task { await vm.importPDF(from: url, employeeId: employeeId) }
                    }
                case .failure(let err):
                    vm.errorMessage = "Import fehlgeschlagen: \(err.localizedDescription)"
                }
            }
            .task { await vm.load(employeeId: employeeId) }
            .alert("Fehler", isPresented: Binding(get: { vm.errorMessage != nil }, set: { _ in vm.errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: { Text(vm.errorMessage ?? "") }
            .sheet(item: Binding(get: { vm.showingPDF.map { IdentifiableWrap(value: $0) } }, set: { wrap in vm.showingPDF = wrap?.value })) { wrap in
                RemotePDFPreviewView(urlString: wrap.value.downloadURL, fileName: wrap.value.fileName)
            }
        }
        .environmentObject(vm) // expose vm to subviews
    }
}
