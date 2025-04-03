//
//  AppConfig.swift
//  Election App
//
//  Created by Andrea Russo on 10/24/24.
//

import Foundation

struct AppConfig {
    static let openAIKey: String = {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("OpenAI API Key not found")
        }
        return key
    }()
}
