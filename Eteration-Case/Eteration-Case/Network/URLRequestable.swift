//
//  URLRequestable.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

// MARK: - URLRequestable Protocol
protocol URLRequestable {
    var path: String { get }
    var method: HTTPMethodType { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any?]? { get }
    
    func createURLRequest() throws -> URLRequest
}

extension URLRequestable {
    var baseURL: String {
        BaseURLProvider.baseURL
    }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    
    func createURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters
                .compactMap { key, value in
                    if let value = value {
                        return URLQueryItem(name: key, value: "\(value)")
                    }
                    return nil
                }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
