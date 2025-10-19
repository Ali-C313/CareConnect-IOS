//
//  CurrentOrderView.swift
//  CareConnect
//
//  Created by Ali Chehab on 19.10.25.
//

import SwiftUI

struct CurrentOrderView: View {
    var body: some View {
        ZStack { GradientBackground() }
            .overlay(
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 24) {
                            VStack { AvatarView(initials: "SM", size: 64); Text("Sarah Müller").foregroundColor(.white) }
                            Image(systemName: "arrow.right").font(.title2).foregroundColor(.white)
                            VStack { AvatarView(initials: "BL", size: 64); Text("Berta Landmann").foregroundColor(.white) }
                        }
                        Divider().background(.white.opacity(0.2))
                        Text("Bemerkungen:").foregroundColor(.red).bold()
                        Text("—").foregroundColor(.white)
                        Text("Live Standort").foregroundColor(.red).bold()
                        MapPlaceholderView()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                PDFCardView(fileName: "Medikamente-Berta-Landmann.pdf")
                                PDFCardView(fileName: "Bericht-1.pdf")
                                PDFCardView(fileName: "Bericht-2.pdf")
                            }.padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                }
            )
            .navigationTitle("Aktueller Auftrag")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CurrentOrderView()
}
