//
//  HomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appState: AppStateViewModel

    var body: some View {
        ZStack { GradientBackground() }
            .overlay(content)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 10) {
                    Circle().fill(appState.staffStatus == .available ? .green : .orange).frame(width: 12, height: 12)
                    Text(appState.staffStatus.rawValue).foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Button { } label: { Image(systemName:"plus.circle.fill").font(.title2).foregroundColor(.white) }
                }.padding(.horizontal)

                HStack(spacing: 12) {
                    statTile(value: "0", label: "Offen", color: .orange)
                    statTile(value: "1", label: "Aktuell", color: .blue)
                    statTile(value: "0", label: "Erledigt", color: .green)
                }.padding(.horizontal)

                Text("🗒️ Aktuelle Aufträge").bold().foregroundColor(.white).padding(.horizontal)
                ZStack { CC.cardBackground() }
                    .frame(height: 90).padding(.horizontal)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("Beate Keller").foregroundColor(.white).bold()
                            Text("Verband wechseln").foregroundColor(.white.opacity(0.85))
                            HStack { Text("👨‍⚕️ Ali Chehab").foregroundColor(.white.opacity(0.8)); Spacer() }
                        }.padding(.horizontal)
                    )

                Text("👥 Mitarbeiter").bold().foregroundColor(.white).padding(.horizontal)
                ZStack { CC.cardBackground() }
                    .frame(height: 80).padding(.horizontal)
                    .overlay(
                        HStack {
                            Circle().fill(.white.opacity(0.2)).frame(width: 44, height: 44)
                                .overlay(Image(systemName:"person.fill").foregroundColor(.white))
                            VStack(alignment: .leading) {
                                Text("Ali Chehab").foregroundColor(.white).bold()
                                Text("Verfügbar").foregroundColor(.green)
                            }
                            Spacer()
                            Circle().fill(.green).frame(width: 10, height: 10)
                        }.padding(.horizontal)
                    )
            }
            .padding(.vertical, 24)
        }
    }

    private func statTile(value: String, label: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.85))
            VStack { Text(value).font(.title).bold(); Text(label).font(.caption).opacity(0.9) }
                .foregroundColor(.white).padding(8)
        }.frame(height: 80)
    }
}
#Preview {
    HomeView()
    .environmentObject(AppStateViewModel())
}
