//
//  PatientHomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import FirebaseAuth

struct PatientHomeView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @State private var showAlert = false
    @State private var showLiveView = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("pillsBackground") // lege ein Asset an
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    Button {
                        showAlert = true
                    } label: {
                        Text("Klick Hier")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(80)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 12)
                    }
                    Spacer()
                }
                .alert("Notfallaktion", isPresented: $showAlert) {
                    Button("Dringlichen Auftrag erstellen") {
                        Task {
                            if let userID = appState.currentUser?.uid {
                                await appState.createEmergencyOrder(for: userID)
                            }
                        }
                    }
                    Button("Notfallkontakt anrufen") {
                        if let url = URL(string: "tel://0123456789") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("Abbrechen", role: .cancel) { }
                } message: {
                    Text("Wählen Sie eine Notfallaktion aus:")
                }
            }
            .navigationTitle("Home")
            .fullScreenCover(isPresented: $showLiveView) { LiveEmergencyView() }
        }
    }
}

#Preview {
    PatientHomeView()
}
