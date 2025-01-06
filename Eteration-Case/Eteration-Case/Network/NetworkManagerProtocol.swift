//
//  NetworkManagerProtocol.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

// MARK: - NetworkManagerProtocol
protocol NetworkManagerProtocol {
    func request<T: Decodable, V: URLRequestable>(
        requestable: V,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

