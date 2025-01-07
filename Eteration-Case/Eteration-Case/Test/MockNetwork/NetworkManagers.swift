//
//  NetworkManager.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

class MockNetworkManager {
    static let shared = MockNetworkManager()
    private init() {}

    func request<T: Decodable>(
        requestable: URLRequestable,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let mockData = MockDataProvider.shared.getMockData(for: requestable) else {
            completion(.failure(NSError(domain: "Mock Data Error", code: 404, userInfo: nil)))
            return
        }

        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: mockData)
            completion(.success(decodedResponse))
        } catch {
            completion(.failure(error))
        }
    }
}
