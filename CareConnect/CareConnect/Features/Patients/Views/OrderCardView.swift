//
//  OrderCardView.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import SwiftUI
import Foundation
import Combine
import MapKit

struct OrderCardView: View {
    let order: PatientOrderDisplayModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(order.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(order.statusText)
                .font(.subheadline)
                .foregroundColor(order.statusColor)
            Text("Datum: \(order.dateFormatted)")
                .font(.footnote)
                .foregroundColor(.secondary)
            if let location = order.employeeLocation {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )), annotationItems: [order]) { _ in
                    MapMarker(coordinate: location, tint: order.statusColor)
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .frame(width: 280)
    }
}

#Preview {
    let exampleOrder = PatientOrderDisplayModel(
        id: "preview-1",
        title: "Beispielauftrag",
        description: "Demo-Vorschauauftrag",
        state: "offen",
        employeeId: "emp001",
        patientLatitude: 48.1351,
        patientLongitude: 11.5820,
        date: Date(),
        employeeName: "Sarah Müller",
        employeePhone: "0176998678443",
        employeeLocation: CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820),
        etaFormatted: "15 Min",
        statusText: "Offen",
        statusColor: .orange
    )
    OrderCardView(order: exampleOrder)
}
