//
//  FavoriteCell.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

class FavoriteCell: UITableViewCell {
    static let identifier = "FavoriteCell"
    private var imageLoadingState: String?
    private var currentImageLoadOperation: Operation?

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = ThemeManager.CornerRadius.large.rawValue
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = ThemeManager.CornerRadius.medium.rawValue
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body1.medium
        label.textColor = ThemeManager.primaryTextColor
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body1.bold
        label.textColor = ThemeManager.primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageLoadOperation?.cancel()
        currentImageLoadOperation = nil
        productImageView.image = UIImage(named: "placeholder")
        imageLoadingState = nil
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        configureConstraints()
    }

    private func configureConstraints() {
        contentView.addSubview(containerView)
        containerView.addSubview(productImageView)
        containerView.addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(priceLabel)

        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ThemeManager.Spacing.small.rawValue),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ThemeManager.Spacing.large.rawValue),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ThemeManager.Spacing.large.rawValue),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ThemeManager.Spacing.medium.rawValue),

            // Product Image
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ThemeManager.Spacing.medium.rawValue),
            productImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),

            // Info Stack View
            infoStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ThemeManager.Spacing.medium.rawValue),
            infoStackView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: ThemeManager.Spacing.medium.rawValue),
            infoStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ThemeManager.Spacing.medium.rawValue),
            infoStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ThemeManager.Spacing.medium.rawValue),
        ])
    }

    // MARK: - Configuration
    func configure(with product: ProductModel) {
        titleLabel.text = product.name
        priceLabel.text = "\(product.price) ₺"
        loadImage(product)
    }
}

private extension FavoriteCell {
    func loadImage(_ product: ProductModel) {
        productImageView.image = UIImage(named: "placeholder")
        currentImageLoadOperation?.cancel()
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
