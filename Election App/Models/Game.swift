//
//  Game.swift
//  Election App
//
//  Created by Andrea Russo on 10/26/24.
//

import Foundation

enum MatchStatus {
    case unselected
    case selected
    case matched
    case incorrect
}

struct GameHeadline: Identifiable {
    let id: UUID
    let headline: Headline
    var status: MatchStatus = .unselected
}

import Foundation

@MainActor
class HeadlinesGameViewModel: ObservableObject {
    @Published var gameHeadlines: [GameHeadline] = []
    @Published var selectedHeadlines: Set<UUID> = []
    @Published var matchedSources: Set<NewsSource> = []
    @Published var showingIncorrectAnimation = false
    @Published var isGameComplete = false
    @Published var moves = 0
    
    private let allHeadlines: [Headline]
    
    init(headlines: [Headline]) {
        // Filter headlines containing keywords
        self.allHeadlines = headlines.filter { headline in
            let text = headline.originalText.lowercased()
            return ["trump", "donald"].contains { text.contains($0) }
        }
        setupNewGame()
    }
    
    func setupNewGame() {
        var gameHeadlines: [GameHeadline] = []
        
        // Get shortest 3 headlines from each source
        for source in [NewsSource.foxNews, .cnn, .theOnion] {
            let sourceHeadlines = allHeadlines
                .filter { $0.source == source }
                .sorted { $0.originalText.count < $1.originalText.count } // Sort by length
                .prefix(3) // Take the 3 shortest
            
            gameHeadlines.append(contentsOf: sourceHeadlines.map {
                GameHeadline(id: UUID(), headline: $0)
            })
        }
        
        // Print the selected headlines for debugging
        for headline in gameHeadlines {
            print("\(headline.headline.source.rawValue) (\(headline.headline.originalText.count) chars): \(headline.headline.originalText)")
        }
        
        // Shuffle the headlines
        self.gameHeadlines = gameHeadlines.shuffled()
        self.selectedHeadlines.removeAll()
        self.matchedSources.removeAll()
        self.isGameComplete = false
        self.moves = 0
    }
    
    func selectHeadline(_ id: UUID) {
        guard !isGameComplete else { return }
        
        if selectedHeadlines.contains(id) {
            selectedHeadlines.remove(id)
            updateGameHeadlineStatuses()
            return
        }
        
        selectedHeadlines.insert(id)
        
        // Check if we have 3 selections
        if selectedHeadlines.count == 3 {
            checkForMatch()
            moves += 1
        }
        
        updateGameHeadlineStatuses()
    }
    
    private func checkForMatch() {
        let selectedGameHeadlines = gameHeadlines.filter { selectedHeadlines.contains($0.id) }
        let sources = Set(selectedGameHeadlines.map { $0.headline.source })
        
        if sources.count == 1, !matchedSources.contains(sources.first!) {
            // Match found!
            matchedSources.insert(sources.first!)
            
            // Check if game is complete
            if matchedSources.count == 3 {
                isGameComplete = true
            }
        } else {
            // No match, show incorrect animation briefly
            showIncorrectAnimation()
        }
        
        selectedHeadlines.removeAll()
    }
    
    private func showIncorrectAnimation() {
        showingIncorrectAnimation = true
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            showingIncorrectAnimation = false
        }
    }
    
    private func updateGameHeadlineStatuses() {
        for i in gameHeadlines.indices {
            if matchedSources.contains(gameHeadlines[i].headline.source) {
                gameHeadlines[i].status = .matched
            } else if selectedHeadlines.contains(gameHeadlines[i].id) {
                gameHeadlines[i].status = .selected
            } else if showingIncorrectAnimation && selectedHeadlines.isEmpty {
                gameHeadlines[i].status = .incorrect
            } else {
                gameHeadlines[i].status = .unselected
            }
        }
    }
}
