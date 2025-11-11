//
//  EmployeeProfileHeaderView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation

struct EmployeeProfileHeaderView: View {
    /// Profil-ViewModel
    @EnvironmentObject var vm: EmployeeProfileViewModel
    /// UI-Inhalt
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                if let urlStr = vm.employee?.profileImageURL,
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 72, height: 72)
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        case .failure:
                            PlaceholderAvatarView()
                        @unknown default:
                            PlaceholderAvatarView()
                        }
                    }
                } else {
                    PlaceholderAvatarView()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.employee?.name ?? "—")
                        .font(.title3.bold())
                        .foregroundColor(CCDesign.textPrimary)
                    Text(vm.employee?.role ?? "—")
                        .foregroundColor(.secondary)
                    Text(vm.employee?.email ?? "—")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    if let st = vm.employee?.staffStatusEnum {
                        HStack(spacing: 6) {
                            Circle().fill(st.color).frame(width: 10, height: 10)
                            Text(st.displayName)
                                .font(.caption)
                                .foregroundColor(st.color)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(CCDesign.card.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: CCDesign.textSecondary.opacity(0.2), radius: 3, x: 0, y: 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vm.employee?.name ?? "Unbekannter Mitarbeiter"), \(vm.employee?.role ?? "")")
    }
}
