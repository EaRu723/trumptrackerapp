//
//  HeadlinesGameView.swift
//  Election App
//
//  Created by Andrea Russo on 10/26/24.
//

import SwiftUI

struct HeadlinesGameView: View {
    @StateObject var viewModel: HeadlinesGameViewModel
    @Environment(\.dismiss) var dismiss
    
    init(headlines: [Headline]) {
        _viewModel = StateObject(wrappedValue: HeadlinesGameViewModel(headlines: headlines))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            header
            
            gameGrid
            
            if viewModel.isGameComplete {
                completionView
            }
            
            sourceProgress
            
            footer
        }
        .padding()
        .navigationTitle("Match The Headlines")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Text("Match groups of 3 headlines from the same news source")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Text("Moves: \(viewModel.moves)")
                .font(.headline)
        }
    }
    
    private var gameGrid: some View {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.gameHeadlines) { gameHeadline in
                    HeadlineGameTile(gameHeadline: gameHeadline) {
                        viewModel.selectHeadline(gameHeadline.id)
                    }
                }
            }
        }
        
        private var sourceProgress: some View {
            HStack {
                ForEach([NewsSource.foxNews, .cnn, .theOnion], id: \.self) { source in
                    HStack {
                        Circle()
                            .fill(viewModel.matchedSources.contains(source) ? source.color : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                        
                        Text(source.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        
        private var completionView: some View {
            VStack(spacing: 12) {
                Text("🎉 Congratulations! 🎉")
                    .font(.title2)
                    .bold()
                
                Text("You completed the game in \(viewModel.moves) moves!")
                    .font(.headline)
                
                Button("Play Again") {
                    viewModel.setupNewGame()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        
        private var footer: some View {
            VStack {
                if !viewModel.isGameComplete {
                    Text("\(3 - viewModel.selectedHeadlines.count) more to check")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Button("Exit Game") {
                    dismiss()
                }
                .padding(.top)
            }
        }
    }

    struct HeadlineGameTile: View {
        let gameHeadline: GameHeadline
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                Text(gameHeadline.headline.originalText)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(backgroundColor)
                    .foregroundColor(foregroundColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(strokeColor, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
        }
        
        private var backgroundColor: Color {
            switch gameHeadline.status {
            case .unselected:
                return Color.gray.opacity(0.1)
            case .selected:
                return Color.blue.opacity(0.2)
            case .matched:
                return gameHeadline.headline.source.color.opacity(0.2)
            case .incorrect:
                return Color.red.opacity(0.2)
            }
        }
        
        private var foregroundColor: Color {
            switch gameHeadline.status {
            case .matched:
                return gameHeadline.headline.source.color
            case .selected:
                return .primary
            default:
                return .primary
            }
        }
        
        private var strokeColor: Color {
            switch gameHeadline.status {
            case .unselected:
                return Color.clear
            case .selected:
                return Color.blue
            case .matched:
                return gameHeadline.headline.source.color
            case .incorrect:
                return Color.red
            }
        }
    }
