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
                        let orders = vm.filteredOrders(selectedFilter)
                        LazyVStack(spacing: 16) {
                            if orders.isEmpty {
                                ContentUnavailableView(
                                    "Keine Aufträge",
                                    systemImage: "doc.text.magnifyingglass",
                                    description: Text("Erstelle einen neuen Auftrag mit dem + Button oben rechts.")
                                )
                                .padding(.top, 40)
                            } else {
                                ForEach(orders) { order in
                                    Button { selectedOrder = order } label: {
                                        OrderCard(order: order)
                                            .environmentObject(appState)
                                    }
                                    .buttonStyle(.plain)
                                }
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
            .sheet(isPresented: Binding(get: {
                selectedOrder != nil
            }, set: { _ in
                selectedOrder = nil
            })) {
                if let order = selectedOrder {
                    OrderDetailView(order: order)
                        .environmentObject(appState)
                }
            }
            .onAppear {
                vm.startListening()
            }
            .onDisappear {
                vm.stopListening()
            }
            .alert("Fehler", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage ?? "Unbekannter Fehler")
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
