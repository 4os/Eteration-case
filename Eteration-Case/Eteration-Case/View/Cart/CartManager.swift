//
//  CardManager.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import CoreData
import UIKit

class CardManager {

    static let shared = CardManager()
    private let context: NSManagedObjectContext

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }

    // MARK: - Add to Card
    func addToCard(productId: String, cardCount: Int = 1) {
        if let existingItem = fetchCardItem(by: productId) {
            existingItem.cardCount += Int16(cardCount)
        } else {
            let newItem = CardItem(context: context)
            newItem.id = productId
            newItem.cardCount = Int16(cardCount)
        }

        saveContext()
        NotificationCenter.default.post(name: .cardUpdated, object: nil)
    }

    // MARK: - Remove from Card
    func removeFromCard(productId: String) {
        if let item = fetchCardItem(by: productId) {
            context.delete(item)
            saveContext()
            NotificationCenter.default.post(name: .cardUpdated, object: nil)
        }
    }

    // MARK: - Fetch Card Items
    func fetchCardItems() -> [CardItem] {
        let fetchRequest: NSFetchRequest<CardItem> = CardItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch card items: \(error)")
            return []
        }
    }

    // MARK: - Fetch Card Item by ID
    private func fetchCardItem(by productId: String) -> CardItem? {
        let fetchRequest: NSFetchRequest<CardItem> = CardItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", productId)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch card item with id \(productId): \(error)")
            return nil
        }
    }

    // MARK: - Clear Card
    func clearCard() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CardItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            saveContext()
            NotificationCenter.default.post(name: .cardUpdated, object: nil)
        } catch {
            print("Failed to clear card: \(error)")
        }
    }

    func increaseCardCount(for id: String) {
           context.performAndWait { [weak self] in
               guard let self = self else { return }
               if let item = fetchCardItem(by: id) {
                   item.cardCount += 1
                   saveContext()
                   DispatchQueue.main.async {
                       NotificationCenter.default.post(name: .countChanged, object: nil)
                   }
               }
           }
       }

    func decreaseCardCount(for id: String) {
        context.performAndWait { [weak self] in
            guard let self = self else { return }
            if let item = fetchCardItem(by: id) {
                item.cardCount -= 1
                if item.cardCount <= 0 {
                    removeFromCard(productId: id)
                } else {
                    saveContext()
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .countChanged, object: nil)
                }
            }
        }
    }
    
    // MARK: - Is Product in Card
    func isProductInCard(productId: String) -> Bool {
        return fetchCardItem(by: productId) != nil
    }

    // MARK: - Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func totalCardItemCount() -> Int {
        let cardItems = fetchCardItems()
        return cardItems.reduce(0) { $0 + Int($1.cardCount) }
    }
}
