//
//  PatientOrdersView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation
import MapKit
import FirebaseAuth

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct PatientOrdersView: View {
    @StateObject var viewModel = PatientOrdersViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var route: MKRoute?
    @State private var distanceText: String = ""
    @State private var etaText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Aktiver Auftrag
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Aktiver Auftrag", systemImage: "location.fill")
                            .font(.title3.bold())
                            .foregroundColor(CCDesign.textPrimary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        if let activeOrder = viewModel.activeOrder {
                            VStack(alignment: .leading, spacing: 16) {
                                if let employeeLocation = viewModel.employeeCoordinate {
                                    // Ziel berechnen
                                    let destination: CLLocationCoordinate2D = {
                                        if let patientLat = activeOrder.patientLatitude,
                                           let patientLon = activeOrder.patientLongitude {
                                            return CLLocationCoordinate2D(latitude: patientLat, longitude: patientLon)
                                        } else {
                                            return CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050)
                                        }
                                    }()

                                    Map(position: $cameraPosition) {
                                        if let route {
                                            MapPolyline(route.polyline)
                                                .stroke(CCDesign.accent, lineWidth: 4)
                                        }
                                        Annotation("Helfer", coordinate: employeeLocation) {
                                            Image(systemName: "figure.walk")
                                                .padding(6)
                                                .background(CCDesign.card)
                                                .clipShape(Circle())
                                        }
                                        Annotation("Ziel", coordinate: destination) {
                                            Image(systemName: "house.fill")
                                                .padding(6)
                                                .background(CCDesign.card)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .frame(height: 260)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                    )
                                    .shadow(color: Color.primary.opacity(0.1), radius: 6, y: 3)
                                    .padding(.horizontal)
                                    .onAppear {
                                        calculateRoute(from: employeeLocation, to: destination)
                                    }
                                    .onChange(of: viewModel.employeeCoordinate) { newValue in
                                        if let newValue {
                                            calculateRoute(from: newValue, to: destination)
                                        }
                                    }

                                    if !distanceText.isEmpty || !etaText.isEmpty {
                                        HStack(spacing: 12) {
                                            if !distanceText.isEmpty {
                                                Label(distanceText, systemImage: "ruler")
                                            }
                                            if !etaText.isEmpty {
                                                Label(etaText, systemImage: "clock")
                                            }
                                        }
                                        .font(.footnote)
                                        .foregroundStyle(CCDesign.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    }
                                } else {
                                    Text("Standort des Mitarbeiters nicht verfügbar")
                                        .foregroundColor(CCDesign.textSecondary)
                                        .frame(height: 240)
                                        .frame(maxWidth: .infinity)
                                        .background(CCDesign.card.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .padding(.horizontal)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Mitarbeiter: \(activeOrder.employeeName)")
                                        .font(.headline)
                                        .foregroundColor(CCDesign.textPrimary)
                                    Text("ETA: \(activeOrder.etaFormatted)")
                                        .font(.subheadline)
                                        .foregroundColor(CCDesign.textSecondary)
                                    Text("Telefon: \(activeOrder.employeePhone)")
                                        .font(.subheadline)
                                        .foregroundColor(CCDesign.textSecondary)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                                .shadow(color: Color.primary.opacity(0.08), radius: 6, y: 3)
                                .padding(.horizontal)
                            }
                            .onAppear {
                                let orderId = activeOrder.id
                                let employeeId = "default"
                                viewModel.startEmployeeLocationListener(orderId: orderId, employeeId: employeeId)
                            }
                            .onDisappear {
                                viewModel.stopEmployeeLocationListener()
                            }
                        } else {
                            Text("Kein aktiver Auftrag verfügbar")
                                .font(.subheadline)
                                .foregroundColor(CCDesign.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                                .shadow(color: Color.primary.opacity(0.05), radius: 4)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 20).fill(CCDesign.card))
                    .padding(.horizontal)

                    // Offene Aufträge Section
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Offene Aufträge", systemImage: "clock.fill")
                            .font(.title3.bold())
                            .foregroundColor(CCDesign.textPrimary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        if viewModel.openOrders.isEmpty {
                            Text("Keine offenen Aufträge.")
                                .font(.subheadline)
                                .foregroundColor(CCDesign.textSecondary)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.openOrders) { order in
                                        OrderCardView(order: order)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                                            .shadow(color: Color.primary.opacity(0.08), radius: 6, y: 3)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 20).fill(CCDesign.card))
                    .padding(.horizontal)

                    // Erledigte Aufträge Section
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Erledigte Aufträge", systemImage: "checkmark.circle.fill")
                            .font(.title3.bold())
                            .foregroundColor(CCDesign.textPrimary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        if viewModel.historyOrders.isEmpty {
                            Text("Keine erledigten Aufträge.")
                                .font(.subheadline)
                                .foregroundColor(CCDesign.textSecondary)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.historyOrders) { order in
                                        OrderCardView(order: order)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                                            .shadow(color: Color.primary.opacity(0.08), radius: 6, y: 3)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 20).fill(CCDesign.card))
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
                .onAppear {
                    if let patientId = Auth.auth().currentUser?.uid {
                        print(patientId)
                        viewModel.fetchActiveOrder(for: patientId)
                        print(viewModel.activeOrder)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(CCDesign.background.ignoresSafeArea())
            .navigationTitle("Live Notruf")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func calculateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, error in
            guard error == nil, let route = response?.routes.first else { return }
            self.route = route

            // Distance text in km
            let km = route.distance / 1000.0
            self.distanceText = String(format: "%.1f km", km)

            // ETA in minutes
            let minutes = Int(ceil(route.expectedTravelTime / 60.0))
            self.etaText = "ETA: \(minutes) min"

            // Fit camera to the route rect
            self.cameraPosition = .rect(route.polyline.boundingMapRect)
        }
    }
}

#Preview {
    PatientOrdersView()
}
