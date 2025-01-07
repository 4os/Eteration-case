//
//  SearchProductsRequests.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import XCTest
@testable import Eteration_Case

final class ModelDecodingTests: XCTestCase {
    
    func testDecodingProductModel() {
        let mockJSON = """
        {
            "id": "1",
            "name": "Product 1",
            "image": "url1",
            "price": "100",
            "description": "desc",
            "model": "model1",
            "brand": "brand1",
            "createdAt": "2024-01-01"
        }
        """.data(using: .utf8)!

        let decodedProduct = try? JSONDecoder().decode(ProductModel.self, from: mockJSON)

        XCTAssertNotNil(decodedProduct, "Decoded product should not be nil")
        XCTAssertEqual(decodedProduct?.id, "1")
        XCTAssertEqual(decodedProduct?.name, "Product 1")
        XCTAssertEqual(decodedProduct?.price, "100")
    }
}
