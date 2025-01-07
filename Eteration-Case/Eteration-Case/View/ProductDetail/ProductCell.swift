//
//  ProductCell.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

protocol ProductCellDelegate: AnyObject {
    func didTapAddToCart(for product: ProductModel)
}

class ProductCell: UICollectionViewCell {
    static let identifier = "ProductCell"
    
    private var currentImageLoadOperation: Operation?
    
    private var imageLoadingState: String?
    weak var delegate: ProductCellDelegate?
    private var product: ProductModel?
    var onAddToCart: (() -> Void)?
    
    private let favoriteButton: FavoriteButton = {
        let button = FavoriteButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body2.semibold
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body2.semibold
        label.textColor = ThemeManager.primaryColor
        label.textAlignment = .left
        return label
    }()
    
    private lazy var addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.backgroundColor = ThemeManager.primaryColor
        button.tintColor = ThemeManager.secondaryTextColor
        button.layer.cornerRadius = ThemeManager.CornerRadius.small.rawValue
        button.titleLabel?.font = FontProvider.Body1.regular
        button.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productImageView, priceLabel, titleLabel, addToCartButton])
        stackView.axis = .vertical
        stackView.spacing = ThemeManager.Spacing.large.rawValue
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNotificationObserver()
        favoriteButton.delegate = self
        configureConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureConstraints() {
        contentView.backgroundColor = .white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(stackView)
        contentView.addSubview(favoriteButton)
        contentView.bringSubviewToFront(favoriteButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ThemeManager.Spacing.medium.rawValue),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ThemeManager.Spacing.medium.rawValue),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ThemeManager.Spacing.medium.rawValue),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ThemeManager.Spacing.medium.rawValue),
            
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),
            addToCartButton.heightAnchor.constraint(equalToConstant: 36),
            
            favoriteButton.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: ThemeManager.Spacing.small.rawValue),
            favoriteButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -ThemeManager.Spacing.small.rawValue),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageLoadOperation?.cancel()
        currentImageLoadOperation = nil
        productImageView.image = UIImage(named: "placeholder")
        imageLoadingState = nil
        product = nil
    }
    
    func configure(product: ProductModel) {
        self.product = product
        titleLabel.text = product.name
        priceLabel.text = "\(product.price) ₺"
        productImageView.image = UIImage(named: "placeholder")
        currentImageLoadOperation?.cancel()
        configureImage(product)
        checkIsInFavorites(product)
    }
    
    
}

// MARK: - Image Dowlnoader
extension ProductCell {
    private func configureImage(_ product: ProductModel) {
        if imageLoadingState == product.image {
            return
        }
        imageLoadingState = product.image
        
        currentImageLoadOperation = AsyncImageLoader.shared.loadImage(from: product.image) { [weak self] image in
            guard let self = self,
                  self.imageLoadingState == product.image else {
                return
            }
            
            self.productImageView.image = image
        }
    }
}

// MARK: - Cart
extension ProductCell {
    @objc private func addToCartTapped() {
        guard let product = product else { return }
        delegate?.didTapAddToCart(for: product)
    }
}

// MARK: - Favorites
extension ProductCell {
    private func checkIsInFavorites(_ product: ProductModel) {
        let isInFavorites = FavoriteManager.shared.isProductInFavorites(productId: product.id)
        favoriteButton.setFavorite(isInFavorites)
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoritesUpdated),
            name: .favoritesUpdated,
            object: nil
        )
    }
    
    @objc private func handleFavoritesUpdated() {
        if let productId = product?.id {
            let isInFavorites = FavoriteManager.shared.isProductInFavorites(productId: productId)
            favoriteButton.setFavorite(isInFavorites)
        }
    }
}

extension ProductCell: FavoriteButtonDelegate {
    func didToggleFavorite(isFavorited: Bool) {
        guard let productId = product?.id else { return }
        if isFavorited {
            FavoriteManager.shared.addToFavorites(productId: productId)
        } else {
            FavoriteManager.shared.removeFromFavorites(productId: productId)
        }
    }
}
