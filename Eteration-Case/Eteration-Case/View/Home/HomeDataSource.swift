//
//  HomeDataSource.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

// MARK: - Data Source

import UIKit

protocol HomeDataSourceDelegate: AnyObject {
    func didSelectProduct(_ product: ProductModel)
    func didTapAddToBasket(_ product: ProductModel)
}

class HomeDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var viewModel: HomeViewModel?
    weak var delegate: HomeDataSourceDelegate?
    var onScrollReachedEnd: (() -> Void)?

    // MARK: - Data Source Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        if viewModel.isSearchActive {
            return viewModel.searchResults.count
        } else if viewModel.isFilterActive {
            return viewModel.filteredProducts.count
        } else {
            return viewModel.products.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell,
              let viewModel = viewModel else {
            return UICollectionViewCell()
        }

        let product: ProductModel
        if viewModel.isSearchActive {
            product = viewModel.searchResults[indexPath.item]
        } else if viewModel.isFilterActive {
            product = viewModel.filteredProducts[indexPath.item]
        } else {
            product = viewModel.products[indexPath.item]
        }
        cell.configure(product: product)
        cell.delegate = self

        cell.onAddToBasket = { [weak self] in
            self?.delegate?.didTapAddToBasket(product)
        }

        return cell
    }

    // MARK: - Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        let product: ProductModel
        if viewModel.isSearchActive {
            product = viewModel.searchResults[indexPath.item]
        } else if viewModel.isFilterActive {
            product = viewModel.filteredProducts[indexPath.item]
        } else {
            product = viewModel.products[indexPath.item]
        }
        delegate?.didSelectProduct(product)
    }

    // MARK: - Layout Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let numberOfItemsPerRow: CGFloat = 2
        let totalPadding = padding * (numberOfItemsPerRow + 1)
        let individualItemWidth = (collectionView.frame.width - totalPadding) / numberOfItemsPerRow

        let estimatedTitleHeight: CGFloat = 40
        let estimatedPriceHeight: CGFloat = 20
        let estimatedButtonHeight: CGFloat = 40
        let imageHeight: CGFloat = individualItemWidth * 0.8

        let totalHeight = imageHeight + estimatedTitleHeight + estimatedPriceHeight + estimatedButtonHeight + (padding * 3)
        return CGSize(width: individualItemWidth, height: totalHeight)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * 2 {
            onScrollReachedEnd?()
        }
    }
}

// MARK: - ProductCellDelegate

extension HomeDataSource: ProductCellDelegate {
    func didTapAddToBasket(for product: ProductModel) {
        delegate?.didTapAddToBasket(product)
    }
}
