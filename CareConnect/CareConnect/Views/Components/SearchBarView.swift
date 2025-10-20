//
//  SearchBarView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct SearchBarView: View {
    
    @State private var text: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.9))
            TextField("Search", text: $text).foregroundColor(.white)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.12)))
        .padding(.horizontal)
    }
}
#Preview {
    SearchBarView()
}
