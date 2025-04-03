//
//  Configuration.swift
//  Election App
//
//  Created by Andrea Russo on 10/24/24.
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey
        case invalidKey
    }
    
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidKey
        }
    }
}

enum SecureKeys {
    static let openAIKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("OpenAI API key not found in Info.plist")
        }
        return key
    }()
}
