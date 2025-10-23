//
//  OrdersView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseAuth

struct OrdersView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var vm = OrdersViewModel()

    @State private var selectedFilter: OrderState = .offen
    @State private var selectedOrder: Order?
    @State private var showingNewOrderSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()
                VStack(spacing: 12) {
                    Picker("Status", selection: $selectedFilter) {
                        ForEach(OrderState.allCases) { s in
                            Text(s.displayName).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 12)

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.orders.filter { $0.state == selectedFilter }) { order in
                                Button { selectedOrder = order } label: {
                                    OrderCard(order: order)
                                        .environmentObject(appState)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Aufträge")
            .toolbar {
                // 👉 Plus-Button oben rechts
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewOrderSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Neuen Auftrag erstellen")
                }
            }
            .sheet(isPresented: $showingNewOrderSheet) {
                NewOrderSheet(isPresented: $showingNewOrderSheet)
                    .environmentObject(appState)
                    .presentationDetents([.medium, .large])
            }
            .task { await vm.load() }
            .sheet(item: Binding(get: {
                selectedOrder.map { IdentifiableWrapper(value: $0) }
            }, set: { wrap in
                selectedOrder = wrap?.value
            })) { wrap in
                OrderDetailView(order: wrap.value)
                    .environmentObject(appState)
            }
        }
    }
}

struct IdentifiableWrapper<T>: Identifiable {
    let id = UUID()
    let value: T
}

#Preview {
    OrdersView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.dark)
}
