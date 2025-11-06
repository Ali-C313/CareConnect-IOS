//
//  PatientOrdersView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import MapKit
import FirebaseAuth

struct PatientOrdersView: View {
    @StateObject var viewModel = PatientOrdersViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Aktiver Auftrag
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Aktiver Auftrag")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if let activeOrder = viewModel.activeOrder {
                            VStack(alignment: .leading, spacing: 16) {
                                if let employeeLocation = activeOrder.employeeLocation {
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                                        center: employeeLocation,
                                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                                    )), annotationItems: [activeOrder]) { _ in
                                        MapMarker(coordinate: employeeLocation, tint: .red)
                                    }
                                    .frame(height: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                                    .padding(.horizontal)
                                } else {
                                    Text("Standort des Mitarbeiters nicht verfügbar")
                                        .foregroundColor(.secondary)
                                        .frame(height: 240)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .padding(.horizontal)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Mitarbeiter: \(activeOrder.employeeName)")
                                        .font(.headline)
                                    Text("ETA: \(activeOrder.etaFormatted)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Telefon: \(activeOrder.employeePhone)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                                .padding(.horizontal)
                            }
                        } else {
                            Text("Kein aktiver Auftrag verfügbar")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.05), radius: 4)
                                .padding(.horizontal)
                        }
                    }

                    // Offene Aufträge Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Offene Aufträge")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                        
                        Rectangle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(height: 2)
                            .padding(.horizontal)

                        if viewModel.openOrders.isEmpty {
                            Text("Keine offenen Aufträge.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.openOrders) { order in
                                        OrderCardView(order: order)
                                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Erledigte Aufträge Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Erledigte Aufträge")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                        
                        Rectangle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(height: 2)
                            .padding(.horizontal)

                        if viewModel.historyOrders.isEmpty {
                            Text("Keine erledigten Aufträge.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.historyOrders) { order in
                                        OrderCardView(order: order)
                                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Live Notruf")
        }
    }
}

#Preview {
    PatientOrdersView()
}
