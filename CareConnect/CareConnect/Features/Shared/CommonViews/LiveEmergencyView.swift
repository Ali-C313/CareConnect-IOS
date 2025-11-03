//
//  LiveEmergencyView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import MapKit

struct LiveEmergencyView: View {
    /// Kartenregion
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Standort in Echtzeit:")
                    .font(.headline)
                    .foregroundColor(.red)

                Map(position: .constant(.region(region))) {
                    Marker("Schnellste", coordinate: region.center)
                }
                .frame(height: 380)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)

                Text("Ihre Helfer/in ist unterwegs!")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)

                HStack(spacing: 16) {
                    Image("sarahMueller") // lege ein Asset an
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ansprechpartner/in")
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                        Text("Sarah Müller")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("22 Jahre – Seit 01.05.2024 beschäftigt")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Tel: 0176 998678443")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()

                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Live Notruf")
        }
    }
}

#Preview {
    LiveEmergencyView()
}
