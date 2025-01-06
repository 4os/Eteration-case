//
//  FavoritesViewModel.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

// MARK: - FavoritesViewModel
class FavoritesViewModel {
    private let favoriteManager = FavoriteManager.shared
    private(set) var products: [ProductModel] = []
    var onProductsUpdated: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    var hasNoFavorites: Bool {
        return products.isEmpty
    }

    func loadFavorites() {
        onLoadingStateChanged?(true)

        let favoriteItems = favoriteManager.getAllFavoriteItems()
        let ids = favoriteItems.map { $0.id }

        let dispatchGroup = DispatchGroup()
        var fetchedProducts: [ProductModel] = []

        for id in ids {
            guard let id = id else { return }
            dispatchGroup.enter()
            let request = GetProductByIdRequest(page: 1, limit: 1, id: id)
            NetworkManager.shared.request(requestable: request, responseType: ProductModel.self) { result in
                switch result {
                case .success(let product):
                    fetchedProducts.append(product)
                case .failure(let error):
                    print("Failed to fetch product with ID \(id): \(error)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.products = fetchedProducts
            self.onLoadingStateChanged?(false)
            self.onProductsUpdated?()
        }
    }
}
