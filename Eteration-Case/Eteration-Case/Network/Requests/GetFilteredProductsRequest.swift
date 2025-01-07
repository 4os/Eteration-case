//
//  GetFilteredProductsRequest.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

struct GetFilteredProductsRequest: URLRequestable {
    var path: String { Endpoints.getProducts.value }
    var method: HTTPMethodType { .GET }
    var headers: [String: String]? { nil }
    private let page: Int
    private let limit: Int
    private let brand: String?
    private let model: String?
    private let sortOption: String?
    private let sortField: String?
    

    var parameters: [String: Any?]? {
        return [
            Parameters.page.rawValue: page,
            Parameters.limit.rawValue: limit,
            Parameters.brand.rawValue: brand,
            Parameters.model.rawValue: model,
            Parameters.sortBy.rawValue: sortOption,
            Parameters.order.rawValue: sortField
        ]
    }

    init(
        page: Int,
        limit: Int,
        brands: [String],
        models: [String],
        sortField: String?,
        sortOption: String?
    ) {
        self.page = page
        self.limit = limit
        self.brand = brands.isEmpty ? nil : brands.joined(separator: "|")
        self.model = models.isEmpty ? nil : models.joined(separator: "|")
        self.sortField = sortField
        self.sortOption = sortOption
    }
}
