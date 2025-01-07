//
//  CartManager.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import CoreData
import UIKit

class CartManager {

    static let shared = CartManager()
    private let context: NSManagedObjectContext

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }

    // MARK: - Add to Cart
    func addToCart(productId: String, cartCount: Int = 1) {
        if let existingItem = fetchCartItem(by: productId) {
            existingItem.cartCount += Int16(cartCount)
        } else {
            let newItem = CartItem(context: context)
            newItem.id = productId
            newItem.cartCount = Int16(cartCount)
        }

        saveContext()
        NotificationCenter.default.post(name: .cartUpdated, object: nil)
    }

    // MARK: - Remove from Cart
    func removeFromCart(productId: String) {
        if let item = fetchCartItem(by: productId) {
            context.delete(item)
            saveContext()
            NotificationCenter.default.post(name: .cartUpdated, object: nil)
        }
    }

    // MARK: - Fetch Cart Items
    func fetchCartItems() -> [CartItem] {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch cart items: \(error)")
            return []
        }
    }

    // MARK: - Fetch Cart Item by ID
    private func fetchCartItem(by productId: String) -> CartItem? {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", productId)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch cart item with id \(productId): \(error)")
            return nil
        }
    }

    // MARK: - Clear Cart
    func clearCart() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CartItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            saveContext()
            NotificationCenter.default.post(name: .cartUpdated, object: nil)
        } catch {
            print("Failed to clear cart: \(error)")
        }
    }

    func increaseCartCount(for id: String) {
           context.performAndWait { [weak self] in
               guard let self = self else { return }
               if let item = fetchCartItem(by: id) {
                   item.cartCount += 1
                   saveContext()
                   DispatchQueue.main.async {
                       NotificationCenter.default.post(name: .countChanged, object: nil)
                   }
               }
           }
       }

    func decreaseCartCount(for id: String) {
        context.performAndWait { [weak self] in
            guard let self = self else { return }
            if let item = fetchCartItem(by: id) {
                item.cartCount -= 1
                if item.cartCount <= 0 {
                    removeFromCart(productId: id)
                } else {
                    saveContext()
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .countChanged, object: nil)
                }
            }
        }
    }
    
    // MARK: - Is Product in Cart
    func isProductInCart(productId: String) -> Bool {
        return fetchCartItem(by: productId) != nil
    }

    // MARK: - Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func totalCartItemCount() -> Int {
        let cartItems = fetchCartItems()
        return cartItems.reduce(0) { $0 + Int($1.cartCount) }
    }
}
