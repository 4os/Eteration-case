//
//  NetworkError.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

// MARK: - NetworkError Enum
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server returned an error with status code \(statusCode)."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
