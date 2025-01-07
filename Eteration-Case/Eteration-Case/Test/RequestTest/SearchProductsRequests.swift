//
//  SearchProductsRequests.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import XCTest
@testable import Eteration_Case

final class ProductSearchTests: XCTestCase {
    
    func testProductSearchRequest() {
        let searchRequest = SearchProductsRequest(page: 1, limit: 10, search: "Search")
        let mockService = MockNetworkManager.shared

        let expectation = XCTestExpectation(description: "Expected to fetch mocked search results")
        mockService.request(with: searchRequest, decodeTo: [ProductModel].self) { response in
            switch response {
            case .success(let searchResults):
                XCTAssertEqual(searchResults.count, 1)
                XCTAssertEqual(searchResults.first?.id, "4")
                XCTAssertEqual(searchResults.first?.name, "Search Product 1")
            case .failure(let error):
                XCTFail("Search request failed: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
