//
//  ProductDetailViewController.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

class ProductDetailViewController: UIViewController {

    // MARK: - Properties
    var viewModel = ProductDetailViewModel()
    var product: ProductModel?

    // MARK: - UI Components
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    private lazy var productImageView: UIImageView = UIImageView()
    private lazy var favoriteButton = FavoriteButton()
    private lazy var titleLabel: UILabel = UILabel()
    private lazy var descriptionLabel: UILabel = UILabel()
    private lazy var addToCartButton = UIButton(type: .system)
    private lazy var bottomBar = UIStackView()
    private lazy var priceContainer = UIStackView()
    private lazy var priceLabel: UILabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        loadProductDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNavigationTransition()
    }

    // MARK: - Setup Methods
    private func configureUI() {
        configureViews()
        layoutUIComponents()
    }

    private func bindViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            self?.toggleLoadingIndicator(isLoading)
        }
        viewModel.onProductFetched = { [weak self] product in
            self?.setupProductDetails(with: product)
        }
        viewModel.onErrorOccurred = { [weak self] error in
            self?.showErrorAlert(message: error)
        }
    }

    private func loadProductDetails() {
        guard let productId = product?.id else { return }
        viewModel.fetchProduct(by: productId)
    }

    private func addNavigationTransition() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        navigationController?.navigationBar.layer.add(transition, forKey: nil)
    }

    // MARK: - UI Configuration
    private func configureViews() {
        loadingIndicator.hidesWhenStopped = true
        view.backgroundColor = .white

        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0

        priceContainer.axis = .vertical
        priceContainer.addArrangedSubview(priceLabel)

        bottomBar.axis = .horizontal
        bottomBar.addArrangedSubview(priceContainer)
        bottomBar.addArrangedSubview(addToCartButton)

        scrollView.addSubview(contentView)
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
    }

    private func layoutUIComponents() {
        [scrollView, bottomBar, loadingIndicator].forEach { view.addSubview($0) }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Actions
    private func toggleLoadingIndicator(_ isLoading: Bool) {
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }

    private func setupProductDetails(with product: ProductModel) {
        titleLabel.text = product.name
        descriptionLabel.text = product.description
        priceLabel.text = "\(product.price) ₺"
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
