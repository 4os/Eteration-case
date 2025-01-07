//
//  CardViewModel.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

protocol CardViewModelDelegate: AnyObject {
    func didChangeLoadingState(isLoading: Bool)
}

class CardViewModel {
    private let cardManager = CardManager.shared
    private(set) var products: [ProductModel] = []
    private(set) var cardCounts: [String: Int] = [:]
    var onProductsUpdated: (() -> Void)?
    var totalPrice: Double = 0
    weak var delegate: CardViewModelDelegate?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCard), name: .cardUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounts), name: .countChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setLoadingState(_ isLoading: Bool) {
        delegate?.didChangeLoadingState(isLoading: isLoading)
    }

    @objc private func reloadCard() {
        loadCardProducts()
    }

    func loadCardProducts() {
        setLoadingState(true)
        let cardItems = cardManager.fetchCardItems()
        cardCounts = Dictionary(uniqueKeysWithValues: cardItems.compactMap { ($0.id ?? "", Int($0.cardCount)) })

        let ids = cardItems.compactMap { $0.id }.sorted()
        let dispatchGroup = DispatchGroup()
        var fetchedProducts: [ProductModel] = []

        for id in ids {
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
            self.products = fetchedProducts.sorted { $0.id < $1.id }
            self.calculateTotalPrice()
            self.setLoadingState(false)
            self.onProductsUpdated?()
        }
    }

    func increaseProductCount(for id: String) {
        DispatchQueue.main.async {
            self.cardManager.increaseCardCount(for: id)
            self.updateCounts()
        }
    }

    func decreaseProductCount(for id: String) {
        DispatchQueue.main.async {
            self.cardManager.decreaseCardCount(for: id)
            self.updateCounts()
        }
    }

    @objc private func updateCounts() {
        let cardItems = cardManager.fetchCardItems()
        cardCounts = Dictionary(uniqueKeysWithValues: cardItems.compactMap { ($0.id ?? "", Int($0.cardCount)) })
        self.calculateTotalPrice()
        onProductsUpdated?()
    }

    private func calculateTotalPrice() {
        totalPrice = products.reduce(0) { result, product in
            guard let count = cardCounts[product.id], let price = Double(product.price) else { return result }
            return result + (Double(count) * price)
        }
    }
}
