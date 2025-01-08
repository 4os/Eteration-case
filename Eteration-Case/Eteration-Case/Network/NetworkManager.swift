//
//  NetworkManager.swift
//  Eteration-Case
//
//  Created by 4os on 6.01.2025.
//

import Foundation

// MARK: - NetworkManager Class
class NetworkManager: NetworkManagerProtocol {

    static let shared = NetworkManager()
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: config)
    }

    func request<T: Decodable, V: URLRequestable>(
        requestable: V,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        do {
            let request = try requestable.createURLRequest()

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.unknownError))
                    print("Request failed with error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknownError))
                    return
                }

                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch let decodingError {
                    completion(.failure(.decodingError(decodingError)))
                }
            }.resume()
        } catch {
            completion(.failure(.invalidURL))
        }
    }
}
