//
//  NetworkError.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidData
    case requestFailed(description: String)
    case decodingFailed
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidData:
            return "The data received from the server was invalid."
        case .requestFailed(let description):
            return "The network request failed with error: \(description)"
        case .decodingFailed:
            return "Failed to decode the response from the server."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
