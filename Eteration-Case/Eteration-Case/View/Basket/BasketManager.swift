//
//  BasketManager.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import CoreData
import UIKit

class BasketManager {

    static let shared = BasketManager()
    private let context: NSManagedObjectContext

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }

    // MARK: - Add to Basket
    func addToBasket(productId: String, basketCount: Int = 1) {
        if let existingItem = fetchBasketItem(by: productId) {
            existingItem.basketCount += Int16(basketCount)
        } else {
            let newItem = BasketItem(context: context)
            newItem.id = productId
            newItem.basketCount = Int16(basketCount)
        }

        saveContext()
        NotificationCenter.default.post(name: .basketUpdated, object: nil)
    }

    // MARK: - Remove from Basket
    func removeFromBasket(productId: String) {
        if let item = fetchBasketItem(by: productId) {
            context.delete(item)
            saveContext()
            NotificationCenter.default.post(name: .basketUpdated, object: nil)
        }
    }

    // MARK: - Fetch Basket Items
    func fetchBasketItems() -> [BasketItem] {
        let fetchRequest: NSFetchRequest<BasketItem> = BasketItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch basket items: \(error)")
            return []
        }
    }

    // MARK: - Fetch Basket Item by ID
    private func fetchBasketItem(by productId: String) -> BasketItem? {
        let fetchRequest: NSFetchRequest<BasketItem> = BasketItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", productId)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch basket item with id \(productId): \(error)")
            return nil
        }
    }

    // MARK: - Clear Basket
    func clearBasket() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BasketItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            saveContext()
            NotificationCenter.default.post(name: .basketUpdated, object: nil)
        } catch {
            print("Failed to clear basket: \(error)")
        }
    }

    func increaseBasketCount(for id: String) {
           context.performAndWait { [weak self] in
               guard let self = self else { return }
               if let item = fetchBasketItem(by: id) {
                   item.basketCount += 1
                   saveContext()
                   DispatchQueue.main.async {
                       NotificationCenter.default.post(name: .countChanged, object: nil)
                   }
               }
           }
       }

    func decreaseBasketCount(for id: String) {
        context.performAndWait { [weak self] in
            guard let self = self else { return }
            if let item = fetchBasketItem(by: id) {
                item.basketCount -= 1
                if item.basketCount <= 0 {
                    removeFromBasket(productId: id)
                } else {
                    saveContext()
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .countChanged, object: nil)
                }
            }
        }
    }
    
    // MARK: - Is Product in Basket
    func isProductInBasket(productId: String) -> Bool {
        return fetchBasketItem(by: productId) != nil
    }

    // MARK: - Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func totalBasketItemCount() -> Int {
        let basketItems = fetchBasketItems()
        return basketItems.reduce(0) { $0 + Int($1.basketCount) }
    }
}
