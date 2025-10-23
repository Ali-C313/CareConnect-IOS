//
//  PatientHomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI

struct PatientHomeView: View {
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
                .alert("Notruf erfolgreich gemeldet", isPresented: $showAlert) {
                    Button("Live Ansicht") { showLiveView = true }
                    Button("Bestätigen", role: .cancel) { }
                } message: {
                    Text("Bitte bewahren Sie Ruhe, es wird jeden Moment Hilfe ankommen.")
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
