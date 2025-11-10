//
//  OrdersView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct OrdersView: View {
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    /// ViewModel
    @StateObject private var vm = OrdersViewModel()

    /// Filterstatus
    @State private var selectedFilter: OrderState = .offen
    /// Ausgewählter Auftrag
    @State private var selectedOrder: Order? {
        didSet {
            if let order = selectedOrder {
                vm.startLiveTracking(for: appState.currentUser?.uid, orderId: order.id)
            } else {
                vm.stopLiveTracking()
            }
        }
    }
    /// Neues Sheet
    @State private var showingNewOrderSheet = false

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background
                    .ignoresSafeArea()
                VStack(spacing: 12) {
                    Picker("Status", selection: $selectedFilter) {
                        ForEach(OrderState.allCases) { s in
                            Text(s.displayName).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 12)

                    let orders = vm.filteredOrders(selectedFilter)

                    ScrollView {
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
                                    Button {
                                        selectedOrder = order
                                    } label: {
                                        OrderCard(order: order)
                                            .environmentObject(appState)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    if vm.isTrackingActive {
                        Label("Live-Tracking aktiv", systemImage: "location.fill")
                            .font(.footnote)
                            .foregroundStyle(CCDesign.info)
                            .padding(.bottom, 6)
                    }
                }
            }
            .navigationTitle("Aufträge")
            .toolbar {
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
            }, set: { newValue in
                if !newValue {
                    selectedOrder = nil
                }
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
