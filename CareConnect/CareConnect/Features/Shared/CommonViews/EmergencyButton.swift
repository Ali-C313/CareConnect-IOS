//
//  EmergencyButton.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import SwiftUI

struct EmergencyButton: View {
    @Binding var isPressed: Bool
    @Binding var showAlert: Bool

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
                Text("Notruf")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.orange]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(30)
            .shadow(color: Color.red.opacity(0.6), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

#Preview {
    struct EmergencyButtonPreview: View {
        @State private var isPressed = false
        @State private var showAlert = false

        var body: some View {
            EmergencyButton(isPressed: $isPressed, showAlert: $showAlert)
                .padding()
                .background(Color(.systemBackground))
        }
    }

    return EmergencyButtonPreview()
}
