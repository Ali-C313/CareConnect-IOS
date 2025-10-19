//
//  StatusView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

// Zeigt und ändert  Mitarbeiterstatus
struct StatusView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @AppStorage("staffStatus") private var staffStatusRaw: String = StaffStatus.available.rawValue
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Dein aktueller Status")
                .font(.headline)
                .padding(.top, 32)
            
            // Aktueller Status
            VStack {
                Image(systemName: appState.staffStatus.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(appState.staffStatus.color)
                Text(appState.staffStatus.rawValue)
                    .font(.title2)
                    .bold()
            }
            .padding(.bottom, 30)
            
            // Button Status
            HStack(spacing: 20) {
                ForEach(StaffStatus.allCases) { status in
                    Button {
                        withAnimation(.spring()) {
                            appState.staffStatus = status
                        }
                    } label: {
                        VStack {
                            Image(systemName: status.icon)
                                .font(.system(size: 28))
                                .padding()
                                .foregroundStyle(status.color)
                            Text(status.rawValue)
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(appState.staffStatus == status ? status.color.opacity(0.15) : Color.gray.opacity(0.08))
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Status")
    }
}

#Preview {
    StatusView()
        .environmentObject(AppStateViewModel())
}
