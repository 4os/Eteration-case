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
    private let managedContext: NSManagedObjectContext

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate couldn't be accessed")
        }
        self.managedContext = appDelegate.persistentContainer.viewContext
    }

    func addToFavorites(productId: String) {
        guard !isProductInFavorites(productId: productId) else {
            print("Product already exists in favorites")
            return
        }
        let favoriteItem = FavoriteItem(context: managedContext)
        favoriteItem.id = productId
        NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
        saveChanges()
    }

    func removeFromFavorites(productId: String) {
        if let itemToDelete = fetchFavoriteItem(by: productId) {
            managedContext.delete(itemToDelete)
            saveChanges()

            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
        }
    }

    func getAllFavoriteItems() -> [FavoriteItem] {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        do {
            return try managedContext.fetch(fetchRequest)
        } catch {
            print("Error while fetching favorite items: \(error)")
            return []
        }
    }

    private func fetchFavoriteItem(by productId: String) -> FavoriteItem? {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", productId)
        do {
            return try managedContext.fetch(fetchRequest).first
        } catch {
            print("Error fetching specific favorite item: \(error)")
            return nil
        }
    }

    private func saveChanges() {
        do {
            try managedContext.save()
        } catch {
            print("Error while saving context: \(error)")
        }
    }

    func isProductInFavorites(productId: String) -> Bool {
        return fetchFavoriteItem(by: productId) != nil
    }
}
