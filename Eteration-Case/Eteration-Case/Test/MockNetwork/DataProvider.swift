//
//  DataProvider.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

class MockDataProvider {
    static let shared = MockDataProvider()
    private init() {}

    func getMockData(for requestable: URLRequestable) -> Data? {
        switch requestable {
        case is GetProductsRequest:
            return MockJSON.getProductsResponse
        case is GetProductByIdRequest:
            return MockJSON.getProductByIdResponse
        case is GetFilteredProductsRequest:
            return MockJSON.getFilteredProductsResponse
        case is SearchProductsRequest:
            return MockJSON.searchProductsResponse
        default:
            return nil
        }
    }
}

struct MockJSON {
    static let getProductsResponse = """
    [
        { "id": "1", "name": "Product 1", "image": "url1", "price": "100", "description": "desc", "model": "model1", "brand": "brand1", "createdAt": "2024-01-01" },
        { "id": "2", "name": "Product 2", "image": "url2", "price": "200", "description": "desc", "model": "model2", "brand": "brand2", "createdAt": "2024-01-02" }
    ]
    """.data(using: .utf8)

    static let getProductByIdResponse = """
    { "id": "1", "name": "Product 1", "image": "url1", "price": "100", "description": "desc", "model": "model1", "brand": "brand1", "createdAt": "2024-01-01" }
    """.data(using: .utf8)

    static let getFilteredProductsResponse = """
    [
        { "id": "3", "name": "Filtered Product 1", "image": "url3", "price": "300", "description": "desc", "model": "model3", "brand": "brand3", "createdAt": "2024-01-03" }
    ]
    """.data(using: .utf8)

    static let searchProductsResponse = """
    [
        { "id": "4", "name": "Search Product 1", "image": "url4", "price": "400", "description": "desc", "model": "model4", "brand": "brand4", "createdAt": "2024-01-04" }
    ]
    """.data(using: .utf8)
}
