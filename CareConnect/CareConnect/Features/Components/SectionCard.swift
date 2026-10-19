//
//  SectionCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Karte mit optionalem Titel und Icon, wird überall als Container benutzt
struct SectionCard<Content: View>: View {
    var title: String?
    var icon: String?
    var iconColor: Color = CCDesign.accent
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon).foregroundColor(iconColor)
                    }
                    Text(title).font(.headline)
                }
            }
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCDesign.cardStyle())
    }
}

#Preview {
    SectionCard(title: "Kontakt", icon: "phone") {
        Text("Inhalt")
    }
    .padding()
    .background(CCDesign.background)
}
