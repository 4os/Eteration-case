//
//  CardCell.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

class CardCell: UITableViewCell {
    static let identifier = "CardCell"
    
    var onIncrease: ((_ productId: String) -> Void)?
    var onDecrease: ((_ productId: String) -> Void)?
    
    private var productId: String?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body1.regular
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body1.regular
        label.textColor = ThemeManager.primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let quantityContainerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("-", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = FontProvider.Heading2.medium
        button.backgroundColor = ThemeManager.secondaryContainterColor
        button.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.secondaryContainterColor
        button.titleLabel?.font = FontProvider.Heading2.medium
        button.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let countContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.primaryColor
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = FontProvider.Body1.regular
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(quantityContainerView)

        quantityContainerView.addArrangedSubview(decreaseButton)
        quantityContainerView.addArrangedSubview(countContainer)
        quantityContainerView.addArrangedSubview(increaseButton)

        countContainer.addSubview(countLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            quantityContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            quantityContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            quantityContainerView.heightAnchor.constraint(equalToConstant: 36),
            quantityContainerView.widthAnchor.constraint(equalToConstant: 120),

            decreaseButton.widthAnchor.constraint(equalTo: quantityContainerView.widthAnchor, multiplier: 0.3),

            countContainer.widthAnchor.constraint(equalTo: quantityContainerView.widthAnchor, multiplier: 0.4),
            countContainer.heightAnchor.constraint(equalTo: quantityContainerView.heightAnchor),

            countLabel.centerXAnchor.constraint(equalTo: countContainer.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: countContainer.centerYAnchor),

            increaseButton.widthAnchor.constraint(equalTo: quantityContainerView.widthAnchor, multiplier: 0.3)
        ])
    }

    
    func configure(with product: ProductModel, count: Int) {
        self.productId = product.id
        titleLabel.text = product.name
        priceLabel.text = "\(product.price) ₺"
        countLabel.text = "\(count)"
    }
    
    @objc private func increaseTapped() {
        guard let productId = productId else { return }
        onIncrease?(productId)
    }
    
    @objc private func decreaseTapped() {
        guard let productId = productId else { return }
        onDecrease?(productId)
    }
}
