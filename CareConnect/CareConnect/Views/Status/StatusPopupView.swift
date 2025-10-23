//
//  StatusPopupView.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI

struct StatusPopupView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @Binding var showPopup: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { withAnimation { showPopup = false } }

            VStack(spacing: 8) {
                Text("Status ändern").font(.headline).padding(.top, 10)

                ForEach(StaffStatus.allCases) { st in
                    Button {
                        withAnimation {
                            Task { await appState.updateCurrentStatus(st) }
                            showPopup = false
                        }
                    } label: {
                        HStack {
                            Circle().fill(st.color).frame(width: 12, height: 12)
                            Text(st.displayName).foregroundColor(.primary)
                            Spacer()
                            if st == appState.staffStatus { Image(systemName: "checkmark") }
                        }
                        .padding(.horizontal).padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }

                Divider().padding(.top, 4)
                Button("Abbrechen", role: .cancel) { withAnimation { showPopup = false } }
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: 280)
            .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
            .shadow(radius: 12)
        }
    }
}
