//
//  ProductDetailViewModel.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

class ProductDetailViewModel {
    private(set) var product: ProductModel?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    var onProductFetched: ((ProductModel) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onErrorOccurred: ((String) -> Void)?

    func fetchProduct(by id: String) {
        updateLoadingState(true)

        let request = GetProductByIdRequest(page: 1, limit: 1, id: id)

        NetworkManager.shared.request(requestable: request, responseType: ProductModel.self) { [weak self] result in
            guard let self = self else { return }

            self.updateLoadingState(false)

            switch result {
            case .success(let product):
                self.product = product
                self.onProductFetched?(product)
            case .failure(let error):
                let errorMessage = "Unable to fetch product: \(error.localizedDescription)"
                self.errorMessage = errorMessage
                self.onErrorOccurred?(errorMessage)
            }
        }
    }

    /// Updates the loading state and notifies listeners.
    /// - Parameter isLoading: The current loading state.
    private func updateLoadingState(_ isLoading: Bool) {
        self.isLoading = isLoading
        self.onLoadingStateChanged?(isLoading)
    }
}
