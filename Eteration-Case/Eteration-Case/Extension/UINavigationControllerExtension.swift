//
//  UINavigationControllerExtension.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
