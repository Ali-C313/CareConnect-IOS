//
//  OrdersView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct OrdersView: View {
    @StateObject private var vm = OrdersViewModel()

    var body: some View {
        ZStack { GradientBackground() }
            .overlay(content)
            .navigationTitle("Aufträge")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.load() }
    }

    private var content: some View {
        VStack {
            Picker("Status", selection: $vm.selectedState) {
                ForEach(OrderState.allCases) { s in Text(s.rawValue).tag(s) }
            }
            .pickerStyle(.segmented)
            .padding()

            if vm.filtered.isEmpty {
                Spacer()
                Text("Keine Aufträge").foregroundColor(.white.opacity(0.7))
                Spacer()
            } else {
                List(vm.filtered) { order in
                    NavigationLink(destination: CurrentOrderView()) {
                        VStack(alignment: .leading) {
                            Text("Auftrag von Sarah Müller → Berta Landmann").bold()
                            Text("Details ansehen").font(.footnote).foregroundColor(.secondary)
                        }
                    }
                }.listStyle(.plain)
            }
        }
    }
}

#Preview {
    OrdersView()
}
