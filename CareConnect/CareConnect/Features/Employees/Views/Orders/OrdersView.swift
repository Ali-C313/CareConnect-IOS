//
//  OrdersView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Auftragsliste mit Filter nach Status
struct OrdersView: View {
    @Environment(AppStateViewModel.self) private var appState
    private let tracker = EmployeeLocationManager.shared
    @State private var selectedFilter: OrderState = .offen
    @State private var showingNewOrderSheet = false

    private var orders: [Order] {
        appState.orders.filter { $0.state == selectedFilter }
    }

    var body: some View {
        VStack(spacing: 16) {
            filterBar

            ScrollView {
                LazyVStack(spacing: 14) {
                    if orders.isEmpty {
                        ContentUnavailableView(
                            tr("Keine Aufträge"),
                            systemImage: "doc.text.magnifyingglass",
                            description: Text(tr("Erstelle einen neuen Auftrag mit dem + Button oben rechts."))
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(orders) { order in
                            NavigationLink {
                                OrderDetailView(orderId: order.id)
                            } label: {
                                OrderCard(order: order)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 8)
            }

            if tracker.isTracking {
                Label(tr("Live-Tracking aktiv"), systemImage: "location.fill")
                    .font(.footnote.bold())
                    .foregroundColor(CCDesign.info)
                    .padding(.bottom, 8)
            }
        }
        .screenBackground()
        .navigationTitle(appState.membership?.orgType == .pflegedienst ? tr("Aufträge") : tr("Hausbesuche"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewOrderSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(tr("Neuen Auftrag erstellen"))
            }
        }
        .sheet(isPresented: $showingNewOrderSheet) {
            NewOrderSheet()
                .presentationDetents([.medium, .large])
        }
    }

    /// Filter offen / aktuell / erledigt mit Anzahl
    private var filterBar: some View {
        HStack(spacing: 6) {
            ForEach(OrderState.allCases) { state in
                let count = appState.orders.filter { $0.state == state }.count
                Text("\(state.displayName) (\(count))")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(selectedFilter == state ? .white : CCDesign.textPrimary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedFilter == state ? CCDesign.accent : CCDesign.card.opacity(0.7))
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) { selectedFilter = state }
                    }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

#Preview {
    NavigationStack { OrdersView() }
        .environment(AppStateViewModel())
}
