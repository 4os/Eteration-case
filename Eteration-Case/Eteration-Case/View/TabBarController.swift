//
//  TabBarController.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//
import UIKit

// MARK: - TabBarController
class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let cartVC = UINavigationController(rootViewController: BasketViewController())
        cartVC.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)

        let favoritesVC = UINavigationController(rootViewController: FavoritesViewController())
        favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star"), tag: 2)

        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)

        self.viewControllers = [homeVC, cartVC, favoritesVC, profileVC]
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge), name: .basketUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge), name: .countChanged, object: nil)

        updateCartBadge()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .basketUpdated, object: nil)
    }

    
    @objc private func updateCartBadge() {
        let basketCount = BasketManager.shared.totalBasketItemCount()
        if let cartTab = self.tabBar.items?[1] {
            cartTab.badgeValue = basketCount > 0 ? "\(basketCount)" : nil
        }
    }
}
