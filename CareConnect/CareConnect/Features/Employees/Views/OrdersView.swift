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
            let orders = vm.filteredOrders(selectedFilter)
            VStack(spacing: 16) {
                // Segmented Picker
                HStack(spacing: 6) {
                    ForEach(OrderState.allCases) { state in
                        Text(state.displayName)
                            .font(.subheadline.bold())
                            .foregroundColor(selectedFilter == state ? .white : CCDesign.textPrimary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedFilter == state ? CCDesign.accent : CCDesign.card.opacity(0.7))
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedFilter = state
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                // Orders List
                ScrollView {
                    LazyVStack(spacing: 14) {
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
                                        .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                                        .shadow(color: CCDesign.textSecondary.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                .scrollContentBackground(.hidden)

                // Live Tracking Indicator
                if vm.isTrackingActive {
                    Label("Live-Tracking aktiv", systemImage: "location.fill")
                        .font(.footnote.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 10).fill(CCDesign.card.opacity(0.6)))
                        .foregroundColor(CCDesign.info)
                        .shadow(color: CCDesign.accent.opacity(0.3), radius: 3)
                        .transition(.opacity)
                        .padding(.bottom, 8)
                }
            }
            .background(CCDesign.background.ignoresSafeArea())
            .navigationTitle("Aufträge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewOrderSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.bold())
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(CCDesign.accent.gradient))
                            .foregroundColor(.white)
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
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OrderAccepted"))) { _ in
                selectedOrder = nil   // Sheet automatisch schließen
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
