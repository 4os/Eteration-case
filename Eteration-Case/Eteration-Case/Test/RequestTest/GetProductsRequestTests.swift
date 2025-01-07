//
//  SearchProductsRequests.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import XCTest
@testable import Eteration_Case

final class GetProductsRequestTests: XCTestCase {
    func testGetProductsRequest() {
        let request = GetProductsRequest(page: 1, limit: 10)
        let mockNetworkManager = MockNetworkManager.shared
        
        let expectation = XCTestExpectation(description: "Request should return mocked products")
        mockNetworkManager.request(requestable: request, responseType: [ProductModel].self) { result in
            switch result {
            case .success(let products):
                XCTAssertEqual(products.count, 2)
                XCTAssertEqual(products[0].id, "1")
                XCTAssertEqual(products[0].name, "Product 1")
            case .failure(let error):
                XCTFail("Request failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetProductByIdRequest() {
        let request = GetProductByIdRequest(page: 1, limit: 1, id: "1")
        let mockNetworkManager = MockNetworkManager.shared

        let expectation = XCTestExpectation(description: "Request should return mocked product by ID")
        mockNetworkManager.request(requestable: request, responseType: ProductModel.self) { result in
            switch result {
            case .success(let product):
                XCTAssertEqual(product.id, "1")
                XCTAssertEqual(product.name, "Product 1")
                XCTAssertEqual(product.price, "100")
            case .failure(let error):
                XCTFail("Request failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
