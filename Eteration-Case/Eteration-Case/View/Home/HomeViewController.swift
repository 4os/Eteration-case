//
//  HomeViewController.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - UI Components

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "No Data Available"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .gray

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    private lazy var loadingContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.isHidden = true
        container.addSubview(loadingIndicator)
        return container
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var selectFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Filter", for: .normal)
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.backgroundColor = ThemeManager.primaryColor
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.font = FontProvider.Body2.bold
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        return button
    }()

    private lazy var clearFiltersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Filters", for: .normal)
        button.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.backgroundColor = ThemeManager.secondaryColor
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.titleLabel?.font = FontProvider.Body2.bold
        button.setTitleColor(.black, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        return button
    }()

    private lazy var filtersLabel: UILabel = {
        let label = UILabel()
        label.text = "Filters:"
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.font = FontProvider.Heading3.regular
        return label
    }()

    private lazy var filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = ThemeManager.Spacing.small.rawValue
        stack.alignment = .center
        stack.distribution = .fill
        stack.addArrangedSubview(filtersLabel)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(selectFilterButton)
        stack.addArrangedSubview(clearFiltersButton)
        return stack
    }()

    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchBar, filterStackView])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HomeCompositionalLayout.createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        return collectionView
    }()

    private let viewModel = HomeViewModel()
    private let dataSource = HomeDataSource()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        setupBindings()
        dataSource.delegate = self

        dataSource.onScrollReachedEnd = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.viewModel.handleScrollReachedEnd(searchQuery: self.searchBar.text)
            }
        }

        viewModel.fetchProducts()
    }

    // MARK: - Setup Methods

    private func setupLayout() {
        view.addSubview(headerStackView)
        view.addSubview(collectionView)
        view.addSubview(loadingContainer)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ThemeManager.Spacing.large.rawValue),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: ThemeManager.Spacing.large.rawValue),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.delegate = self
        dataSource.viewModel = viewModel
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "E-Market"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }

    // MARK: - Actions

    @objc private func filterTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .overFullScreen
        present(filterVC, animated: true)
    }

    @objc private func clearFilters() {
        viewModel.clearFilters()
        viewModel.fetchProducts(reset: true)
    }
}

// MARK: - Extensions

extension HomeViewController: HomeViewModelDelegate {
    func didChangeEmptyState(isEmpty: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.emptyStateView.isHidden = !isEmpty
            self.collectionView.isHidden = isEmpty
        }
    }

    func didUpdateProducts() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }

    func didFailWithError(_ error: String) {
        DispatchQueue.main.async {
            print("Error: \(error)")
        }
    }

    func didChangeLoadingState(isLoading: Bool) {
        DispatchQueue.main.async {
            self.loadingContainer.isHidden = !isLoading
            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.isSearchActive = !searchText.isEmpty
        if searchText.isEmpty {
            viewModel.fetchProducts(reset: true)
        } else {
            viewModel.searchProducts(query: searchText, reset: true)
        }
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.isSearchActive = false
        viewModel.fetchProducts(reset: true)
        collectionView.reloadData()
    }
}

extension HomeViewController: FilterDelegate {
    func applyFilter(sortBy: SortModel?, brands: [String], models: [String]) {
        viewModel.isFilterActive = true
        viewModel.isSearchActive = false
        viewModel.fetchFilteredProducts(sortBy: sortBy, brands: brands, models: models, reset: true)

        if viewModel.filteredProducts.isEmpty {
            let alert = UIAlertController(
                title: "No Results",
                message: "No results found for the selected filters.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

extension HomeViewController: HomeDataSourceDelegate {
    func didSelectProduct(_ product: ProductModel) {
        DispatchQueue.main.async { [weak self] in
            let detailVC = ProductDetailViewController()
            detailVC.product = product
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func didTapAddToCart(_ product: ProductModel) {
        if CartManager.shared.isProductInCart(productId: product.id) {
            showAlert(title: "Already Added", message: "This product is already in your Cart.")
        } else {
            CartManager.shared.addToCart(productId: product.id, cartCount: 1)
            showAlert(title: "Success", message: "Product added to your cart.")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
