//
//  PDFCardView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct PDFCardView: View {
    
    var fileName: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.12))
                .overlay(Text("PDF").font(.title).bold().opacity(0.3).foregroundColor(.white))
                .frame(height: 80)
            Text(fileName).font(.caption).lineLimit(1).foregroundColor(.white)
        }
        .padding(8)
        .frame(width: 180)
    }
}
#Preview {
    PDFCardView(fileName: "Beispiel.pdf")
}
