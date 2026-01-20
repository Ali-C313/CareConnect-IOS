//
//  GeoapifyService.swift
//  CareConnect
//
//  Created by Ali Chehab on 01.11.25.
//

import Foundation

struct GeoapifyPrediction: Identifiable, Codable, Equatable {
    let id = UUID()
    let formatted: String
}

struct GeoapifyResponse: Codable {
    let results: [GeoapifyPrediction]
}

final class GeoapifyService {
    static let shared = GeoapifyService()

    // API-Key laden (aus Secrets.xcconfig)
    private let apiKey = Secrets.geoapifyApiKey

    /// Adressen abrufen
    func fetchSuggestions(for query: String, countryCode: String? = nil, limit: Int = 5) async throws -> [GeoapifyPrediction] {
        guard !apiKey.isEmpty else { return [] }
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return [] }

        // API-URL bauen
        var urlString = "https://api.geoapify.com/v1/geocode/autocomplete?text=\(encoded)&limit=\(limit)&apiKey=\(apiKey)"
        if let cc = countryCode { urlString += "&filter=countrycode:\(cc.lowercased())" }
        guard let url = URL(string: urlString) else { return [] }

        // Anfrage ausführen
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // Antwort decodieren
        let decoded = try JSONDecoder().decode(GeoapifyResponse.self, from: data)
        return decoded.results
    }
}
