//
//  URLRequestable.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

// MARK: - URLRequestable Protocol Definition
/// Defines the necessary properties and methods for creating a URLRequest.
protocol URLRequestable {
    /// The endpoint path for the request.
    var path: String { get }
    /// The HTTP method type for the request.
    var method: HTTPMethodType { get }
    /// Additional headers for the request.
    var headers: [String: String]? { get }
    /// Parameters for the request, if any.
    var parameters: [String: Any?]? { get }
    
    /// Creates a URLRequest object using the defined properties.
    func createURLRequest() throws -> URLRequest
}

extension URLRequestable {
    /// Base URL for all requests, provided by BaseURLProvider.
    var baseURL: String {
        BaseURLProvider.baseURL
    }
    
    /// Default headers, set to `nil` by default.
    var headers: [String: String]? { nil }
    
    /// Default parameters, set to `nil` by default.
    var parameters: [String: Any]? { nil }
    
    /// Combines the baseURL, path, and parameters to create a URLRequest object.
    func createURLRequest() throws -> URLRequest {
        // Initialize URL components using the base URL and path.
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        // Add query items if parameters are provided.
        if let parameters = parameters {
            urlComponents.queryItems = parameters.compactMap { key, value in
                if let value = value {
                    return URLQueryItem(name: key, value: "\(value)")
                }
                return nil
            }
        }
        
        // Create the final URL.
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // Construct the URLRequest with the method and headers.
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add headers to the request.
        if let headers = headers {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
