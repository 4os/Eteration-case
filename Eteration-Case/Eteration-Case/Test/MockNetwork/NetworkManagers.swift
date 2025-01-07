//
//  NetworkManager.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

final class MockNetworkManager {
    static let shared = MockNetworkManager()
    private init() {}

    func request<T: Decodable>(
        with requestable: URLRequestable,
        decodeTo type: T.Type,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        guard let mockPayload = MockDataProvider.shared.getMockData(for: requestable) else {
            let error = NSError(domain: "MockDataUnavailable", code: 404, userInfo: [NSLocalizedDescriptionKey: "No mock data found for the request."])
            completionHandler(.failure(error))
            return
        }

        do {
            let parsedResponse = try JSONDecoder().decode(type, from: mockPayload)
            completionHandler(.success(parsedResponse))
        } catch let decodingError {
            completionHandler(.failure(decodingError))
        }
    }
}
