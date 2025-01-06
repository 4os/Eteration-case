//
//  FavoriteManager.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import CoreData
import UIKit

class FavoriteManager {
    static let shared = FavoriteManager()
    private let context: NSManagedObjectContext

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }

    func addToFavorites(productId: String) {
        if isProductInFavorites(productId: productId) {
            print("Product is already in favorites")
            return
        }
        let favorite = FavoriteItem(context: context)
        favorite.id = productId
        NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
        saveContext()
    }

    func removeFromFavorites(productId: String) {
        if let favoriteItem = fetchFavoriteItem(by: productId) {
            context.delete(favoriteItem)
            saveContext()

            // Notification gönder
            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
        }
    }

    func getAllFavoriteItems() -> [FavoriteItem] {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }

    private func fetchFavoriteItem(by productId: String) -> FavoriteItem? {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", productId)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch favorite item: \(error)")
            return nil
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func isProductInFavorites(productId: String) -> Bool {
        return fetchFavoriteItem(by: productId) != nil
    }
}
