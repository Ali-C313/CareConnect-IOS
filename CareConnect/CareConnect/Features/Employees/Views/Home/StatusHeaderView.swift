//
//  StatusHeaderView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eigener Status und Zugang zur Suche
struct StatusHeaderView: View {
    @Environment(AppStateViewModel.self) private var appState

    private var status: StaffStatus { appState.currentEmployee?.currentStatus ?? .available }

    var body: some View {
        HStack {
            Menu {
                ForEach(StaffStatus.allCases) { option in
                    Button {
                        appState.updateStatus(option)
                    } label: {
                        Label(option.displayName, systemImage: option.icon)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Circle().fill(status.color).frame(width: 12, height: 12)
                    Text(status.displayName).fontWeight(.semibold)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(CCDesign.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider().frame(height: 28)

            NavigationLink {
                GlobalSearchView()
            } label: {
                Label(tr("Suche…"), systemImage: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            }
        }
        .frame(height: 44)
        .padding()
        .background(CCDesign.cardStyle())
    }
}
