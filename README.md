# 📱 CareConnect  
**Die moderne All-in-One Pflege-App für Pflegekräfte & Patienten**

CareConnect ist eine intuitive, moderne und sichere iOS-App, die speziell für Pflegekräfte entwickelt wurde, um den Alltag einfacher, effizienter und übersichtlicher zu gestalten.  
Die App unterstützt bei Patientenverwaltung, Medikamentenplanung, Terminen, Live-Notrufen, Profilverwaltung und vielem mehr.

---

# 🌟 Features

## 🏠 Startseite
- Begrüßung des Nutzers  
- Großer Notruf-Button  
- Schnellzugriff auf aktuelle Aufträge  

**Screenshot:**  
<img src="images/home.jpg" alt="Mitarbeiter-Home" width="300"/>
<img src="images/pat.home.jpg" alt="Patienten-Home" width="300"/>

---

## 🧑‍🤝‍🧑 Patientenverwaltung
- Vollständige Liste aller Patienten  
- Adresse, Kontakt, medizinische Infos  
- Standort via Apple Maps  
- Profil bearbeiten  

**Screenshot:**  
<img src="images/patienten_liste.jpg" alt="Patientenliste" width="300"/>

---

## 📝 Auftragsmanagement
- Aktuelle, offene und erledigte Aufträge  
- Detailansicht mit Live-Karte und Ankunftszeit  
- Abschließen mit Leistungsnachweis und Unterschrift  
- Wiederkehrende Aufträge aus Verordnungen  

**Screenshot:**  
<img src="images/auftraege.jpg" alt="Mitarbeiter-Aufträge" width="300"/>
<img src="images/auftraege1.jpg" alt="Mitarbeiter-Aufträge" width="300"/>
<img src="images/pat.auftraege.jpg" alt="Patienten-Aufträge" width="300"/>

---

## 💊 Medikamentenverwaltung
- Medikamente sortiert nach **Morgen / Mittag / Abend**  
- Neues Medikament hinzufügen  
- Übersichtliche Struktur  

**Screenshot:**  
<img src="images/medikamente.jpg" alt="Medikamente" width="300"/>

---

## 📅 Termine
- Arzttermine planen  
- Übersichtliche Listenansicht  
- Termine hinzufügen  

**Screenshot:**  
<img src="images/termine.jpg" alt="Termine" width="300"/>

---

## 👤 Patienten-Profil bearbeiten
- Vorname, Nachname, Adresse  
- Telefonnummer, E-Mail  
- Allergien, Krankengeschichte  
- Profilbild ändern  
- Passwort ändern  

**Screenshot:**  
<img src="images/patient_profil.jpg" alt="Patientenprofil" width="300"/>

---

## ⚙️ Einstellungen
- Profil anzeigen und bearbeiten  
- Organisation wechseln, verwalten oder verlassen  
- Benachrichtigungen und Standort-Freigabe  
- Dark Mode / Light Mode  
- Sprache (Deutsch, Englisch, Türkisch, Arabisch, Spanisch)  
- Abmelden  

**Screenshot:**  
<img src="images/einstellungen.jpg" alt="Mitarbeiter-Einstellungen" width="300"/>
<img src="images/pat.einstellungen.jpg" alt="Patienten-Einstellungen" width="300"/>

---

# 🛠️ Tech-Stack

| Bereich | Technologie |
|--------|-------------|
| Sprache | Swift |
| UI Framework | SwiftUI |
| Architektur | MVVM mit Protokollen & Repositories |
| Backend | Firebase Firestore |
| Authentifizierung | Firebase Auth |
| Storage | Firebase Storage |
| Push | Firebase Cloud Messaging |
| Karten | Apple Maps |
| iOS Version | iOS 26 |
| IDE | Xcode 18+ |

---

# 📁 Projektstruktur

```
CareConnect/
├── App/                  # Einstieg, AppDelegate, AppContainer, RootView
├── Core/
│   ├── Models/           # Datenmodelle (Codable, wie in Firestore), Enums/ für Status und Rollen
│   ├── Firebase/         # FirebaseManager, Collection-Namen, Listener
│   ├── Repositories/     # Pro Bereich: Repository (Protocol), RepositoryImpl (Firebase) und MockRepository
│   ├── Services/         # Standort, Benachrichtigungen, Karten
│   ├── ViewModels/       # AppStateViewModel (Sitzung + Live-Daten)
│   ├── Extensions/       # Hilfen für String, Datum, Links
│   ├── Localization/     # Übersetzungen
│   └── Design/           # Farben und Stil
├── Features/
│   ├── Auth/             # Login & Registrierung
│   ├── Organization/     # Organisation gründen, beitreten, verwalten
│   ├── Employees/        # Mitarbeiter-App
│   ├── Patients/         # Patienten-App
│   ├── Settings/         # Gemeinsame Einstellungs-Bereiche
│   └── Components/       # Wiederverwendbare UI-Bausteine
└── Resources/            # Assets, Farben, GoogleService-Info.plist
```

In den Xcode-Previews laufen automatisch die Mock-Repositories mit Beispieldaten, dafür wird kein Firebase gebraucht.

Die App nutzt dasselbe Firebase-Projekt wie die Android-Version (CareConnect-KMP), Daten sind also auf beiden Plattformen gleich.

---

# 🚀 Installation

### Voraussetzungen:
- macOS + Xcode 18 oder neuer  
- Firebase-Projekt  
- GoogleService-Info.plist  

### Schritte:
1. Repository klonen  
2. Projekt in Xcode öffnen  
3. GoogleService-Info.plist einfügen  
4. App auf Gerät oder Simulator starten  

---

# 📚 Verwendung

- Patientenprofil anlegen & bearbeiten  
- Medikamente verwalten  
- Termine planen  
- Aufträge einsehen  
- Notruf schnell auslösen  
- Profil und Passwort ändern  

---

# 🧭 Roadmap

- Kalender mit Erinnerungen  
- Exportfunktionen (PDF/CSV)  
- Leistungsnachweise als PDF  

---

# 👤 Kontakt

**Entwickler:** Ali Chehab  
🔗 LinkedIn: www.linkedin.com/in/ali-chehab-32a7a7364  

---

**CareConnect – Ihre Gesundheit in besten Händen.**

