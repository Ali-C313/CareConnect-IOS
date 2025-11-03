//
//  PatientProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseFirestore

struct PatientProfileView: View {
    
    /// Patienten-ID
    let patientId: String
    /// ViewModel
    @StateObject private var viewModel = PatientProfileViewModel()
    /// Sheet anzeigen
    @State private var showEmergencyContactSheet = false
    
    /// UI-Inhalt
    var body: some View {
        ScrollView {
            if let patient = viewModel.patient {
                VStack(alignment: .leading, spacing: 16) {
                    // 🔹 Kopfbereich (Card)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            if let urlString = patient.profileImageURL, let url = URL(string: urlString), !urlString.isEmpty {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                            } else {
                                AvatarView(initials: initials(from: patient.name), size: 64)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(patient.name)
                                    .font(.title2).bold()
                                    .foregroundColor(.primary)

                                if let age = patient.age {
                                    Text("\(age) Jahre")
                                        .foregroundColor(.secondary)
                                }

                                // Adresse + Stadt (tappbar → Maps)
                                let addrText = [patient.address ?? "", patient.city ?? ""].filter{ !$0.isEmpty }.joined(separator: ", ")
                                if !addrText.isEmpty {
                                    Button {
                                        let encoded = addrText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                        if let url = URL(string: "http://maps.apple.com/?q=" + encoded) { UIApplication.shared.open(url) }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "map.fill")
                                            Text(addrText)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                } else {
                                    HStack(spacing: 6) {
                                        Image(systemName: "map")
                                        Text("Keine Adresse angegeben")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            Spacer()
                            Button { showEmergencyContactSheet = true } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "person.crop.circle.badge.exclam")
                                        .font(.title2)
                                    Text("Notfall")
                                        .font(.caption)
                                }
                            }
                            .accessibilityLabel("Notfallkontakt anzeigen")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )

                    Divider().background(.white.opacity(0.2))

                    // 🔹 Kontakt (Patient)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kontakt")
                            .font(.headline)
                            .foregroundColor(.primary)
                        VStack(alignment: .leading, spacing: 10) {
                            // Telefon (tap to call)
                            if let phone = patient.phone, !phone.isEmpty {
                                InfoButtonRow(system: "phone.fill", title: "Telefon", label: phone) {
                                    if let url = URL(string: "tel://" + phone.replacingOccurrences(of: " ", with: "")) { UIApplication.shared.open(url) }
                                }
                            } else {
                                InfoRow(system: "phone", title: "Telefon", value: "Keine Telefonnummer angegeben")
                            }
                            // E‑Mail (tap to compose)
                            if let email = patient.email, !email.isEmpty {
                                InfoButtonRow(system: "envelope.fill", title: "E‑Mail", label: email) {
                                    if let url = URL(string: "mailto:" + email) { UIApplication.shared.open(url) }
                                }
                            } else {
                                InfoRow(system: "envelope", title: "E‑Mail", value: "Keine E‑Mail‑Adresse angegeben")
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )

                    Divider().background(.white.opacity(0.2))

                    // 🔹 Medikamente
                    if let meds = patient.medications, !meds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medikamente")
                                .font(.headline)
                                .foregroundColor(.primary)
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(meds) { med in
                                    HStack(spacing: 8) {
                                        Image(systemName: "pills.fill")
                                        Text(med.name)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }

                    // 🔹 Allergien
                    if let allergies = patient.allergies, !allergies.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Allergien")
                                .font(.headline)
                                .foregroundColor(.primary)
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "allergens")
                                Text(allergies)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )

                        Divider().background(.white.opacity(0.2))
                    }

                    Divider().background(.white.opacity(0.2))

                    // 🔹 Medizinische Vorgeschichte
                    if let mh = patient.medicalHistory, !mh.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medizinische Vorgeschichte")
                                .font(.headline)
                                .foregroundColor(.primary)
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "stethoscope")
                                Text(mh)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )

                        Divider().background(.white.opacity(0.2))
                    }

                    // 🔹 History
                    if let history = patient.history, !history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Historie")
                                .font(.headline)
                                .foregroundColor(.primary)
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(history, id: \.self) { entry in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "clock.fill")
                                        Text(entry)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }

                    // 🔹 Geburtstag
                    if patient.birthDate != nil || patient.age != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Geburtstag")
                                .font(.headline)
                                .foregroundColor(.primary)
                            VStack(alignment: .leading, spacing: 6) {
                                if let ts = patient.birthDate {
                                    let dateText = formatDate(ts)
                                    InfoRow(system: "calendar", title: "Geburtsdatum", value: dateText)
                                    let derived = computeAge(from: ts)
                                    if let derived = derived { InfoRow(system: "figure.arms.open", title: "Alter (berechnet)", value: "\(derived)") }
                                }
                                if let explicitAge = patient.age {
                                    InfoRow(system: "figure.arms.open", title: "Alter (Angabe)", value: "\(explicitAge)")
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )

                        Divider().background(.white.opacity(0.2))
                    }

                    // 🔹 Notizen
                    if let notes = patient.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notizen")
                                .font(.headline)
                                .foregroundColor(.primary)
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "note.text")
                                Text(notes)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )

                        Divider().background(.white.opacity(0.2))
                    }


                    // 🔹 Karte
                    let addr = [patient.address ?? "", patient.city ?? ""].joined(separator: ", ")
                    AddressMapView(address: addr.isEmpty ? nil : addr, title: patient.name)
                }
                .padding()
            } else {
                ProgressView("Lade Patientendaten …")
                    .padding()
            }
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .task {
            await viewModel.loadPatient(id: patientId)
        }
        .navigationTitle("Profil")
        .sheet(isPresented: $showEmergencyContactSheet) {
            if let contact = viewModel.patient?.emergencyContact {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Notfallkontakt")
                        .font(.title2).bold()
                        .padding(.bottom, 4)

                    // Card mit allen Kontaktinfos
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(system: "person.fill", title: "Name", value: contact.name)
                        if let relation = contact.relation, !relation.isEmpty {
                            InfoRow(system: "person.2.fill", title: "Beziehung", value: relation)
                        }
                        if let age = contact.age {
                            InfoRow(system: "figure.arms.open", title: "Alter", value: "\(age)")
                        }

                        // Telefon (tappbar)
                        if let phone = contact.phone, !phone.isEmpty {
                            InfoButtonRow(system: "phone.fill", title: "Telefon", label: phone) {
                                if let url = URL(string: "tel://" + phone.replacingOccurrences(of: " ", with: "")) { UIApplication.shared.open(url) }
                            }
                        } else {
                            InfoRow(system: "phone", title: "Telefon", value: "Keine Telefonnummer angegeben")
                        }

                        // E-Mail (tappbar)
                        if let email = contact.email, !email.isEmpty {
                            InfoButtonRow(system: "envelope.fill", title: "E‑Mail", label: email) {
                                if let url = URL(string: "mailto:" + email) { UIApplication.shared.open(url) }
                            }
                        } else {
                            InfoRow(system: "envelope", title: "E‑Mail", value: "Keine E‑Mail‑Adresse angegeben")
                        }

                        // Adresse (tappbar)
                        if let address = contact.address, !address.isEmpty {
                            InfoButtonRow(system: "map.fill", title: "Adresse", label: address) {
                                let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                if let url = URL(string: "http://maps.apple.com/?q=" + encoded) { UIApplication.shared.open(url) }
                            }
                        } else {
                            InfoRow(system: "map", title: "Adresse", value: "Keine Adresse angegeben")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )

                    Spacer(minLength: 0)
                }
                .padding()
                .presentationDetents([.medium, .large])
            } else {
                VStack(spacing: 16) {
                    Text("Kein Notfallkontakt vorhanden.")
                        .font(.headline)
                        .padding(.top)
                    
                    Button {
                        viewModel.newEmergencyContact = EmergencyContact(
                            name: "",
                            relation: "",
                            phone: "",
                            email: "",
                            address: "",
                            age: nil
                        )
                        viewModel.showAddEmergencyContactSheet = true
                    } label: {
                        Label("Notfallkontakt hinzufügen", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                if viewModel.showAddEmergencyContactSheet {
                    EmergencyContactEditorView(viewModel: viewModel)
                }
            }
        }
    }
    
    /// Initialen erzeugen
    private func initials(from name: String) -> String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
    }
}

private struct InfoRow: View {
    let system: String
    let title: String
    let value: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: system)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).foregroundColor(.secondary)
                Text(value).foregroundColor(.primary)
            }
        }
    }
}

private struct InfoButtonRow: View {
    let system: String
    let title: String
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: system)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline).foregroundColor(.secondary)
                    Text(label).foregroundColor(.blue)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
        }
    }
}

extension PatientProfileView {
    /// Datum formatieren
    private func formatDate(_ ts: Timestamp) -> String {
        let date = ts.dateValue()
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "de_DE")
        fmt.dateFormat = "dd.MM.yyyy"
        return fmt.string(from: date)
    }
    
    /// Alter berechnen
    private func computeAge(from ts: Timestamp) -> Int? {
        let date = ts.dateValue()
        let comps = Calendar.current.dateComponents([.year], from: date, to: Date())
        return comps.year
    }
}

#Preview {
    PatientProfileView(patientId: "exampleId123")
        .preferredColorScheme(.dark)
}
