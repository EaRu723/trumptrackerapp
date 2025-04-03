//
//  Headline.swift
//  Election App
//
//  Created by Andrea Russo on 10/24/24.
//

import Foundation
import SwiftUI

struct HeadlineResponse: Codable {
    let query: [[String]]
    let results: [HeadlineItem]
}

struct HeadlineItem: Codable, Identifiable {
    let Headline: String
    let Link: String
    var id: String { Headline }
}

struct Headline: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let source: NewsSource
    let link: String  // Add this property
    var spoofedText: String?
    var isProcessing: Bool
    
    init(id: UUID = UUID(), originalText: String, source: NewsSource, link: String, spoofedText: String? = nil, isProcessing: Bool = false) {
        self.id = id
        self.originalText = originalText
        self.source = source
        self.link = link
        self.spoofedText = spoofedText
        self.isProcessing = isProcessing
    }
    
    init(from headlineItem: HeadlineItem, source: NewsSource) {
        self.id = UUID()
        self.originalText = headlineItem.Headline
        self.source = source
        self.link = headlineItem.Link
        self.spoofedText = nil
        self.isProcessing = false
    }
}

enum NewsSource: String, Codable {
    case foxNews = "Fox News"
    case cnn = "CNN"
    case theOnion = "The Onion"
    
    var color: Color {
        switch self {
        case .foxNews: return .red
        case .cnn: return .blue
        case .theOnion: return .green
        }
    }
}
