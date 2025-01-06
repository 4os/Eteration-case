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
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    func request<T: Decodable, V: URLRequestable>(
        requestable: V,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        do {
            let urlRequest = try requestable.createURLRequest()

            session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(.unknownError))
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknownError))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch let decodingError {
                    completion(.failure(.decodingError(decodingError)))
                }
            }.resume()
        } catch {
            completion(.failure(.invalidURL))
        }
    }
}
