//
//  HeadlinesViewModel.swift
//  Election App
//
//  Created by Andrea Russo on 10/24/24.
//

import Foundation

@MainActor
class HeadlinesViewModel: ObservableObject {
    @Published private(set) var headlines: [Headline] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let headlineService: HeadlineService
    private let xAIService: XAIService
    
    private let keywordFilters = [
        "trump",
        "donald",
        "kamala",
        "harris",
        "walz",
        "vance",
        "biden"
    ]
    
    init(headlineService: HeadlineService = HeadlineService(), xAIService: XAIService = XAIService()) {
        self.headlineService = headlineService
        self.xAIService = xAIService
    }
    
    func addHeadline(_ text: String, source: NewsSource, link: String = "") {
        headlines.append(Headline(originalText: text, source: source, link: link))
    }
    
    func loadHeadlines() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allHeadlines = try await headlineService.fetchAllHeadlines()
            let filteredHeadlines = filterHeadlines(allHeadlines)
            headlines = interweaveHeadlines(filteredHeadlines)
        } catch {
            errorMessage = "Error fetching headlines: \(error)"
            print("Error loading headlines: \(error)")
        }
        
        isLoading = false
    }
    
    private func filterHeadlines(_ headlines: [Headline]) -> [Headline] {
        headlines.filter { headline in
            let headlineLower = headline.originalText.lowercased()
            return keywordFilters.contains { keyword in
                headlineLower.contains(keyword.lowercased())
            }
        }
    }
    
    private func interweaveHeadlines(_ headlines: [Headline]) -> [Headline] {
        let foxHeadlines = headlines.filter { $0.source == .foxNews }
        let cnnHeadlines = headlines.filter { $0.source == .cnn }
        let onionHeadlines = headlines.filter { $0.source == .theOnion }
        
        let maxCount = max(foxHeadlines.count, max(cnnHeadlines.count, onionHeadlines.count))
        
        var interwoven: [Headline] = []
        
        for i in 0..<maxCount {
            if i < foxHeadlines.count { interwoven.append(foxHeadlines[i]) }
            if i < cnnHeadlines.count { interwoven.append(cnnHeadlines[i]) }
            if i < onionHeadlines.count { interwoven.append(onionHeadlines[i]) }
        }
        
        return interwoven
    }

    func spoofHeadline(_ headline: Headline) {
        guard let index = headlines.firstIndex(where: { $0.id == headline.id }) else { return }
        
        headlines[index].isProcessing = true
        
        Task {
            do {
                let spoofedText = try await xAIService.spoofHeadline(headline.originalText)
                headlines[index].spoofedText = spoofedText
            } catch {
                errorMessage = "Failed to spoof headline: \(error.localizedDescription)"
                print("Error spoofing headline: \(error)")
            }
            headlines[index].isProcessing = false
        }
    }
}
