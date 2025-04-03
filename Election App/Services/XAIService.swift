//
//  xAIService.swift
//  Election App
//
//  Created by Andrea Russo on 10/24/24.
//

import Foundation

class XAIService {
    // Comment out or remove the hardcoded key
    private let baseURL = "https://api.x.ai/v1/chat/completions" // Update to xAI's endpoint
    // Uncomment the apiKey property
    private let apiKey: String
//    private let baseURL = "https://api.x.ai/v1/chat/completions"

    // Uncomment the initializer
    init() throws {
        // Get API key from configuration
        self.apiKey = try Configuration.value(for: "XAI_API_KEY")
    }
    
    func spoofHeadline(_ headline: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "grok-beta",  // Using xAI's model name, confirm this from xAI documentation
            "messages": [
                ["role": "user", "content": "Pretend you are a writer for the onion. Create a satirical version of this headline: '\(headline)'. return only the headline"]
            ],
            "max_tokens": 100,
            "temperature": 0.7
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                // Print error response for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error Response: \(errorString)")
                }
                throw URLError(.badServerResponse)
            }
            
            let xAIResponse = try JSONDecoder().decode(XAIResponse.self, from: data)
            return xAIResponse.choices.first?.message.content ?? "No response generated"
            
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Response models
    struct XAIResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
        }
        
        struct Message: Codable {
            let content: String
        }
    }
}
