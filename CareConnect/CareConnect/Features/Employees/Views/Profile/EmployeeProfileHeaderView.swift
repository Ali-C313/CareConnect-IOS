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
            .background(CCDesign.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(.separator).opacity(0.25), radius: 3, x: 0, y: 2)
        }
    }
}