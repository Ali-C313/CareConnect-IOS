//
//  EmergencyButton.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Großer Notruf-Button mit kleinem Drück-Effekt
struct EmergencyButton: View {
    @Binding var showAlert: Bool
    @State private var isPressed = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPressed = false
                    showAlert = true
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "phone.fill.arrow.up.right")
                    .font(.system(size: 24, weight: .bold))
                Text(tr("Notruf"))
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(30)
            .shadow(color: .red.opacity(0.6), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

#Preview {
    EmergencyButton(showAlert: .constant(false))
        .padding()
}
