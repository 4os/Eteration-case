//
//  CartViewModel.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

protocol CartViewModelDelegate: AnyObject {
    func didChangeLoadingState(isLoading: Bool)
}

class CartViewModel {
    private let cartManager = CartManager.shared
    private(set) var products: [ProductModel] = []
    private(set) var cartCounts: [String: Int] = [:]
    var onProductsUpdated: (() -> Void)?
    var totalPrice: Double = 0
    weak var delegate: CartViewModelDelegate?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCartData), name: .cartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCartCounts), name: .countChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func updateLoadingState(_ isLoading: Bool) {
        delegate?.didChangeLoadingState(isLoading: isLoading)
    }

    @objc private func reloadCartData() {
        loadCartItems()
    }

    func loadCartItems() {
        updateLoadingState(true)
        let items = cartManager.fetchCartItems()
        cartCounts = Dictionary(uniqueKeysWithValues: items.compactMap { ($0.id ?? "", Int($0.cartCount)) })

        let productIDs = items.compactMap { $0.id }.sorted()
        let group = DispatchGroup()
        var retrievedProducts: [ProductModel] = []

        for productID in productIDs {
            group.enter()
            let request = GetProductByIdRequest(page: 1, limit: 1, id: productID)
            NetworkManager.shared.request(requestable: request, responseType: ProductModel.self) { result in
                switch result {
                case .success(let product):
                    retrievedProducts.append(product)
                case .failure(let error):
                    print("Error loading product with ID \(productID): \(error)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.products = retrievedProducts.sorted { $0.id < $1.id }
            self.calculateTotal()
            self.updateLoadingState(false)
            self.onProductsUpdated?()
        }
    }

    func increaseProductCount(for id: String) {
        DispatchQueue.main.async {
            self.cartManager.increaseCartCount(for: id)
            self.refreshCartCounts()
        }
    }

    func decreaseProductCount(for id: String) {
        DispatchQueue.main.async {
            self.cartManager.decreaseCartCount(for: id)
            self.refreshCartCounts()
        }
    }

    @objc private func refreshCartCounts() {
        let items = cartManager.fetchCartItems()
        cartCounts = Dictionary(uniqueKeysWithValues: items.compactMap { ($0.id ?? "", Int($0.cartCount)) })
        self.calculateTotal()
        onProductsUpdated?()
    }

    private func calculateTotal() {
        totalPrice = products.reduce(0) { total, product in
            guard let count = cartCounts[product.id], let price = Double(product.price) else { return total }
            return total + (Double(count) * price)
        }
    }
}
