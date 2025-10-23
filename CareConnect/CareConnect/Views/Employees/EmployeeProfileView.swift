//
//  EmployeeProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import MapKit
import PDFKit
import QuickLook

struct EmployeeProfileView: View {
    let employeeId: String

    @StateObject private var vm = EmployeeProfileViewModel()
    @State private var showImporter = false
    @State private var fileToImport: URL?
    @State private var showPDFPreview = false
    @State private var tempDownloadedURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        profileHeader
                        workScheduleSection
                        documentsSection
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
                    Button {
                        showImporter = true
                    } label: {
                        Label("Dokument hinzufügen", systemImage: "doc.badge.plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        Task { await vm.importPDF(from: url, employeeId: employeeId) }
                    }
                case .failure(let err):
                    vm.errorMessage = "Import fehlgeschlagen: \(err.localizedDescription)"
                }
            }
            .task {
                await vm.load(employeeId: employeeId)
            }
            .alert("Fehler", isPresented: Binding(get: { vm.errorMessage != nil },
                                                  set: { _ in vm.errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage ?? "")
            }
            .sheet(item: Binding(get: {
                vm.showingPDF.map { IdentifiableWrap(value: $0) }
            }, set: { wrap in
                vm.showingPDF = wrap?.value
            })) { wrap in
                RemotePDFPreviewView(urlString: wrap.value.downloadURL,
                                     fileName: wrap.value.fileName)
            }
        }
    }

    // MARK: - Sections

    private var profileHeader: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                if let urlStr = vm.employee?.profileImageURL,
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 72, height: 72)
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                        case .failure:
                            placeholderAvatar
                        @unknown default:
                            placeholderAvatar
                        }
                    }
                } else {
                    placeholderAvatar
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.employee?.name ?? "—")
                        .font(.title3.bold())
                        .foregroundColor(CCDesign.textPrimary)
                    Text(vm.employee?.role ?? "—")
                        .foregroundColor(.secondary)
                    Text(vm.employee?.email ?? "—")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    if let st = vm.employee?.staffStatusEnum {
                        HStack(spacing: 6) {
                            Circle().fill(st.color).frame(width: 10, height: 10)
                            Text(st.displayName)
                                .font(.caption)
                                .foregroundColor(st.color)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(CCDesign.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(.separator).opacity(0.25), radius: 3, x: 0, y: 2)
        }
    }

    private var workScheduleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Arbeitszeiten")
                .font(.headline)
                .foregroundColor(CCDesign.textPrimary)

            HStack {
                Label("\(vm.workSchedule.weeklyHours) Std/Woche",
                      systemImage: "clock")
                Spacer()
                Label("\(vm.workSchedule.shiftStart) – \(vm.workSchedule.shiftEnd)",
                      systemImage: "clock.badge.checkmark")
            }
            .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vm.workSchedule.workDays, id: \.self) { day in
                        Text(day)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(CCDesign.card)
                            .clipShape(Capsule())
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

    private var documentsSection: some View {
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
                        // ✅ Swipe-to-delete integriert
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

    private var placeholderAvatar: some View {
        Circle()
            .fill(.white.opacity(0.18))
            .frame(width: 72, height: 72)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
            )
            .accessibilityLabel("Avatar")
    }
}

// MARK: - Remote PDF Preview (lädt Datei temporär und zeigt PDFKit)

struct RemotePDFPreviewView: View {
    let urlString: String
    let fileName: String

    @State private var localURL: URL?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Lade PDF …")
                } else if let localURL,
                          let pdfDoc = PDFDocument(url: localURL) {
                    PDFKitRepresentable(document: pdfDoc)
                        .ignoresSafeArea()
                } else {
                    Text("PDF konnte nicht angezeigt werden.")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle(fileName)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await downloadIfNeeded()
            }
        }
    }

    private func downloadIfNeeded() async {
        guard let remote = URL(string: urlString) else {
            isLoading = false; return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: remote)
            let tmp = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".pdf")
            try data.write(to: tmp)
            self.localURL = tmp
        } catch {
            print("⚠️ PDF Download fehlgeschlagen:", error.localizedDescription)
        }
        isLoading = false
    }
}

struct PDFKitRepresentable: UIViewRepresentable {
    let document: PDFDocument
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.document = document
        v.autoScales = true
        return v
    }
    func updateUIView(_ uiView: PDFView, context: Context) { }
}

// Hilfswrapper für Sheet .item
struct IdentifiableWrap<T>: Identifiable {
    let id = UUID()
    let value: T
}

#Preview {
    EmployeeProfileView(employeeId: "emp_demo_001")
}
