//
//  ContentView.swift
//  Election App
//
//  Created by Andrea Russo on 10/24/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HeadlinesViewModel()
    @State private var selectedSource: NewsSource?
    @State private var showingGame = false
    
    var filteredHeadlines: [Headline] {
        guard let source = selectedSource else {
            return viewModel.headlines
        }
        return viewModel.headlines.filter { $0.source == source }
    }
    
    var body: some View {
        NavigationView {
            List {
                Picker("News Source", selection: $selectedSource) {
                    Text("All").tag(Optional<NewsSource>.none)
                    Text("Fox").tag(Optional<NewsSource>.some(.foxNews))
                    Text("CNN").tag(Optional<NewsSource>.some(.cnn))
                    Text("The Onion").tag(Optional<NewsSource>.some(.theOnion))
                }
                .pickerStyle(.segmented)
                .padding(.vertical)
                
                ForEach(filteredHeadlines) { headline in
                    HeadlineRowView(headline: headline) {
                        viewModel.spoofHeadline(headline)
                    }
                }
            }
            .navigationTitle("Trump Tracker")
                        .toolbar {
                            Button {
                                showingGame = true
                            } label: {
                                Label("Play Game", systemImage: "gamecontroller")
                            }
                        }
                        .sheet(isPresented: $showingGame) {
                            NavigationView {
                                HeadlinesGameView(headlines: viewModel.headlines)
                            }
                        }
            .refreshable {
                await viewModel.loadHeadlines()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                await viewModel.loadHeadlines()
            }
        }
    }
}

struct HeadlineRowView: View {
    let headline: Headline
    let onSpoofTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(headline.source.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(headline.source.color)
                    .cornerRadius(4)
                
                Spacer()
                Button(headline.spoofedText == nil ? "Spoof" : "Regenerate") {
                    onSpoofTap()
                }
                .buttonStyle(.bordered)
                .disabled(headline.isProcessing)
                .cornerRadius(4)
                .font(.caption)
            }
            
            Link(destination: URL(string: headline.link) ?? URL(string: "https://theonion.com")!) {
                Text(headline.originalText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            if let spoofedText = headline.spoofedText {
                Text(spoofedText)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if headline.isProcessing {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 4)
    }
}
