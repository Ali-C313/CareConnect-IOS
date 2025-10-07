//
//  DummyData.swift
//  CareConnect
//
//  Created by Ali Chehab on 07.10.25.
//

import Foundation

final class DummyData {
    static let shared = DummyData()

    let mitarbeiter: [Mitarbeiter]
    let patienten: [Patient]
    let auftraege: [Auftrag]

    private init() {
        mitarbeiter = [
            Mitarbeiter(vorname: "Anna", nachname: "Müller", alter: 29, status: .verfügbar, rolle: "Sanitäterin"),
            Mitarbeiter(vorname: "Max", nachname: "Schmidt", alter: 34, status: .imEinsatz, rolle: "Notarzt"),
            Mitarbeiter(vorname: "Tobias", nachname: "Becker", alter: 41, status: .pause, rolle: "Pflegeleiter")
        ]

        patienten = [
            Patient(name: "Peter Wagner", geburtsjahr: 1968, adresse: "Hauptstr. 12, Berlin", notfallkontakt: "Elke Wagner – 0123 456789"),
            Patient(name: "Maria Huber", geburtsjahr: 1984, adresse: "Nebenweg 5, Hamburg", notfallkontakt: "Hans Huber – 0987 654321")
        ]

        auftraege = [
            Auftrag(titel: "Herzinfarkt", beschreibung: "Brustschmerzen, Verdacht auf Herzinfarkt", ort: "Industriestr. 3", status: .aktuell, patient: patienten[0], mitarbeiter: mitarbeiter[1]),
            Auftrag(titel: "Sturz", beschreibung: "Patient nach Sturz", ort: "Parkallee 7", status: .offen, patient: patienten[1], mitarbeiter: nil),
            Auftrag(titel: "Nachkontrolle", beschreibung: "Vitalwerte prüfen", ort: "Krankenhaus A", status: .erledigt, patient: patienten[0], mitarbeiter: mitarbeiter[0])
        ]
    }
}
