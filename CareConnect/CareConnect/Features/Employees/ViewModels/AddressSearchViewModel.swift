//
//  AddressSearchViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 01.11.25.
//

import Foundation
import Combine

@MainActor
final class AddressSearchViewModel: ObservableObject {
    /// Suchtext
    @Published var query: String = ""
    /// Vorschläge
    @Published var suggestions: [GeoapifyPrediction] = []
    /// Lädt Status
    @Published var isLoading: Bool = false
    /// Fehlermeldung
    @Published var errorMessage: String?

    private let service = GeoapifyService.shared
    private var searchTask: Task<Void, Never>?

    /// Reagiert auf Suche
    func onQueryChanged(countryCode: String? = "de") {
        searchTask?.cancel()
        let currentQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard currentQuery.count >= 3 else {
            suggestions = []
            return
        }
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
                if Task.isCancelled { return }
                await self.search(countryCode: countryCode)
            } catch { }
        }
    }

    /// Suche starten
    func search(countryCode: String? = "de") async {
        isLoading = true
        errorMessage = nil
        do {
            let results = try await service.fetchSuggestions(for: query, countryCode: countryCode, limit: 5)
            suggestions = results
        } catch {
            suggestions = []
            errorMessage = "Suche fehlgeschlagen: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// Vorschlag wählen
    func select(_ suggestion: GeoapifyPrediction) {
        query = suggestion.formatted
        suggestions = []
    }
}
