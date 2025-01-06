//
//  Endpoints.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

// MARK: Endpoints enum
enum Endpoints {
    case getProducts
    case getFilteredProducts
    case searchProducts
    case getProductById(_ id: String)
}

extension Endpoints {
    var value: String {
        switch self {
        case .getProducts:
            return "/products"
        case .searchProducts:
            return "/products"
        case .getFilteredProducts:
            return "/filteredProducts"
        case .getProductById(let id):
            return "/products/\(id)"
        }
    }
}
