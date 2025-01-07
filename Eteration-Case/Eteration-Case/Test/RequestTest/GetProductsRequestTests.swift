//
//  SearchProductsRequests.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import XCTest
@testable import Eteration_Case

final class ProductRequestsTests: XCTestCase {
    
    func testFetchingProducts() {
        let productRequest = GetProductsRequest(page: 1, limit: 10)
        let networkMock = MockNetworkManager.shared
        
        let expectation = XCTestExpectation(description: "Expected to fetch mocked product list")
        networkMock.request(with: productRequest, decodeTo: [ProductModel].self) { response in
            switch response {
            case .success(let productList):
                XCTAssertEqual(productList.count, 2)
                XCTAssertEqual(productList.first?.id, "1")
                XCTAssertEqual(productList.first?.name, "Product 1")
            case .failure(let error):
                XCTFail("Request failed unexpectedly: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchingProductDetailsById() {
        let productDetailRequest = GetProductByIdRequest(page: 1, limit: 1, id: "1")
        let networkMock = MockNetworkManager.shared

        let expectation = XCTestExpectation(description: "Expected to fetch mocked product details by ID")
        networkMock.request(with: productDetailRequest, decodeTo: ProductModel.self) { response in
            switch response {
            case .success(let productDetail):
                XCTAssertEqual(productDetail.id, "1")
                XCTAssertEqual(productDetail.name, "Product 1")
                XCTAssertEqual(productDetail.price, "100")
            case .failure(let error):
                XCTFail("Request failed unexpectedly: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
