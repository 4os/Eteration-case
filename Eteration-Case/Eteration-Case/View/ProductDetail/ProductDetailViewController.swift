//
//  ProductDetailViewController.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    // MARK: - Properties
    var product: ProductModel?
    var viewModel = ProductDetailViewModel()
    
    // MARK: - UI Components
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var favoriteButton: FavoriteButton = {
        let button = FavoriteButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Heading2.bold
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body2.regular
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomBar: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.backgroundColor = .white
        view.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var priceContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private lazy var priceTitle: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Heading3.medium
        label.textColor = ThemeManager.primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Price:"
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Heading3.bold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addToBasketButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Basket", for: .normal)
        button.titleLabel?.font = FontProvider.Heading3.bold
        button.backgroundColor = ThemeManager.primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        fetchProductDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        navigationController?.navigationBar.layer.add(transition, forKey: nil)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        view.addSubview(bottomBar)
        view.addSubview(loadingIndicator)
        
        priceContainer.addArrangedSubview(priceTitle)
        priceContainer.addArrangedSubview(priceLabel)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(productImageView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        bottomBar.addArrangedSubview(priceContainer)
        bottomBar.addArrangedSubview(addToBasketButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),
            
            priceContainer.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            priceContainer.trailingAnchor.constraint(equalTo: addToBasketButton.leadingAnchor, constant: 16),
            addToBasketButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            priceContainer.widthAnchor.constraint(equalToConstant: 200),
            priceContainer.heightAnchor.constraint(equalToConstant: 100),
            
            addToBasketButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            addToBasketButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            addToBasketButton.widthAnchor.constraint(equalToConstant: 120),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        title = product?.name
    }
    
    // MARK: - ViewModel Bindings
    private func setupBindings() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            self?.toggleLoadingIndicator(isLoading)
        }
        
        viewModel.onProductFetched = { [weak self] product in
            DispatchQueue.main.async {
                self?.configureProductDetails(with: product)
                self?.setupActions()
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }
    // MARK: - Fetch Product Details
    private func fetchProductDetails() {
        guard let productId = product?.id else { return }
        viewModel.fetchProduct(by: productId)
    }
    
    // MARK: - UI Methods
    private func toggleLoadingIndicator(_ isLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isLoading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func configureProductDetails(with product: ProductModel) {
        titleLabel.text = product.name
        descriptionLabel.text = product.description
        priceLabel.text = "\(product.price) ₺"
        checkIsInFavorites()
        
        guard let imageURL = URL(string: product.image) else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageURL),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.productImageView.image = image
                }
            }
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        favoriteButton.delegate = self
        addToBasketButton.addTarget(self, action: #selector(handleAddToBasket), for: .touchUpInside)
    }
    
    func checkIsInFavorites() {
        guard let product = product else { return }
        let isInFavorites = FavoriteManager.shared.isProductInFavorites(productId: product.id)
        favoriteButton.setFavorite(isInFavorites)
    }
    
    // MARK: - Actions
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleAddToBasket() {
        guard let product = product else { return }
        
        if BasketManager.shared.isProductInBasket(productId: product.id) {
            showAlert(title: "Already Added", message: "This product is already in your Basket.")
        } else {
            BasketManager.shared.addToBasket(productId: product.id, basketCount: 1)
            showAlert(title: "Success", message: "Product added to your basket.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ProductDetailViewController: FavoriteButtonDelegate {
    func didToggleFavorite(isFavorited: Bool) {
        guard let productId = product?.id else { return }
        if isFavorited {
            FavoriteManager.shared.addToFavorites(productId: productId)
        } else {
            FavoriteManager.shared.removeFromFavorites(productId: productId)
        }
    }
}
