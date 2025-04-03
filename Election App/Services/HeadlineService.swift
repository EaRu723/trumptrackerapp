//
//  HeadlineService.swift
//  Election App
//
//  Created by Andrea Russo on 10/24/24.
//

import Foundation

class HeadlineService {
    private let xAIService = XAIService()
    
    private let foxNewsURL = "https://lsd.so/api?query=--%20Extracting%20headlines%20and%20links%20from%20Fox%20News%20homepage.%0A%0A--%20We%20identify%20the%20article%20containers%20and%20then%20select%20the%20headline%20text%20and%20associated%20links.%0A%0AFROM%20https%3A%2F%2Fwww.foxnews.com%2F%0A%7C%3E%20GROUP%20BY%20article%0A%0A%7C%3E%20SELECT%20h3.title%20AS%20Headline%2C%20a%40href%20AS%20Link"
    private let cnnURL = "https://lsd.so/huxley?query=give%20me%20every%20Headline%20and%20Link%20on%20this%20page&url=https%3A%2F%2Fwww.cnn.com%2Fpolitics"
    private let onionURL = "https://lsd.so/huxley?query=give%20me%20every%20Headline%20and%20Link%20on%20this%20page&url=https%3A%2F%2Ftheonion.com%2Fpolitics%2F"
    
    func fetchAllHeadlines() async throws -> [Headline] {
        async let foxNews = fetchHeadlines(from: foxNewsURL, source: .foxNews)
        async let cnn = fetchHeadlines(from: cnnURL, source: .cnn)
        async let onion = fetchHeadlines(from: onionURL, source: .theOnion)

        let (foxResults, cnnResults, onionResults) = try await (foxNews, cnn, onion)
        return foxResults + cnnResults + onionResults
    }
    
    private func fetchHeadlines(from urlString: String, source: NewsSource) async throws -> [Headline] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(HeadlineResponse.self, from: data)
        
        return response.results.map { Headline(from: $0, source: source) }
    }
    
    func spoofHeadline(_ headline: String) async throws -> String {
        return try await xAIService.spoofHeadline(headline)
    }
}
