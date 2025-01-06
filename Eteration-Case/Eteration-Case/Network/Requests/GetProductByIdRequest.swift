//
//  GetProductByIdRequest.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

struct GetProductByIdRequest: URLRequestable {
    var path: String
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

    init(page: Int, limit: Int, id: String) {
        self.page = page
        self.limit = limit
        self.path = Endpoints.getProductById(id).value
    }
}
