//
//  EmployeeProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import UniformTypeIdentifiers

/// Profil eines Mitarbeiters mit Arbeitszeiten und Dokumenten
struct EmployeeProfileView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var viewModel = EmployeeProfileViewModel()
    @State private var showImporter = false
    @State private var documentToDelete: EmployeeDocument?

    let employeeId: String

    private var employee: Employee? { appState.employee(id: employeeId) }

    var body: some View {
        Group {
            if let employee {
                ScrollView {
                    VStack(spacing: 16) {
                        EmployeeProfileHeaderView(employee: employee)
                        EmployeeWorkScheduleView(schedule: employee.schedule)
                        EmployeeDocumentsView(
                            documents: viewModel.documents,
                            isUploading: viewModel.isUploading,
                            onAdd: { showImporter = true },
                            onDelete: { documentToDelete = $0 }
                        )
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    tr("Mitarbeiter nicht gefunden"),
                    systemImage: "person.crop.circle.badge.questionmark"
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle(tr("Mitarbeiter"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.startListening(employeeId: employeeId) }
        .onDisappear { viewModel.stopListening() }
        // Nur PDFs
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.pdf]) { result in
            if case .success(let url) = result {
                viewModel.uploadPDF(from: url, employeeId: employeeId)
            }
        }
        .alert(
            tr("Dokument löschen?"),
            isPresented: Binding(get: { documentToDelete != nil }, set: { if !$0 { documentToDelete = nil } })
        ) {
            Button(tr("Löschen"), role: .destructive) {
                if let documentToDelete { viewModel.deleteDocument(documentToDelete, employeeId: employeeId) }
            }
            Button(tr("Abbrechen"), role: .cancel) {}
        } message: {
            Text(documentToDelete?.fileName ?? "")
        }
        .messageAlert(tr("Fehler"), message: $viewModel.errorMessage)
    }
}

#Preview {
    NavigationStack { EmployeeProfileView(employeeId: "1") }
        .environment(AppStateViewModel())
}
