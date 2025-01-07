//
//  SearchProductsRequests.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import XCTest
@testable import Eteration_Case

final class GetFilteredProductsRequestTests: XCTestCase {
    func testGetFilteredProductsRequest() {
        let request = GetFilteredProductsRequest(
            page: 1,
            limit: 10,
            brands: ["brand3"],
            models: ["model3"],
            sortField: "price",
            sortOption: "asc"
        )
        let mockNetworkManager = MockNetworkManager.shared

        let expectation = XCTestExpectation(description: "Request should return mocked filtered products")
        mockNetworkManager.request(with: request, decodeTo: [ProductModel].self) { result in
            switch result {
            case .success(let products):
                XCTAssertEqual(products.count, 1)
                XCTAssertEqual(products[0].id, "3")
                XCTAssertEqual(products[0].name, "Filtered Product 1")
            case .failure(let error):
                XCTFail("Request failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
