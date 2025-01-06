//
//  GetProductsRequest.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

struct GetProductsRequest: URLRequestable {
    var path: String { Endpoints.getProducts.value }
    var method: HTTPMethodType { .GET }
    var headers: [String: String]? { nil }
    private let page: Int
    private let limit: Int

    var parameters: [String: Any?]? {
        return [
            Parameters.page.rawValue: page,
            Parameters.limit.rawValue: limit
        ]
    }

    init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
    }
}
