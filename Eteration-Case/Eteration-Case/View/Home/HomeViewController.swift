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
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        return searchBar
    }()
    
    private lazy var selectFilterButton: UIButton = {
        let selectFilterButton =  UIButton(type: .system)
        selectFilterButton.setTitle("Select Filter", for: .normal)
        selectFilterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        selectFilterButton.setContentHuggingPriority(.required, for: .horizontal)
        selectFilterButton.translatesAutoresizingMaskIntoConstraints = false
        selectFilterButton.backgroundColor = ThemeManager.secondaryColor
        selectFilterButton.titleLabel?.font =  FontProvider.Body2.regular
        selectFilterButton.setTitleColor(ThemeManager.primaryTextColor, for: .normal)
        return selectFilterButton
    }()
        
    private lazy var clearFiltersButton: UIButton = {
        let clearFiltersButton = UIButton(type: .system)
        clearFiltersButton.setTitle("Clear Filters", for: .normal)
        clearFiltersButton.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
        clearFiltersButton.setContentHuggingPriority(.required, for: .horizontal)
        clearFiltersButton.translatesAutoresizingMaskIntoConstraints = false
        clearFiltersButton.backgroundColor = ThemeManager.secondaryColor
        clearFiltersButton.titleLabel?.font =  FontProvider.Body2.regular
        clearFiltersButton.setTitleColor(ThemeManager.primaryTextColor, for: .normal)
        return clearFiltersButton
    }()
    
    private lazy var filtersLabel: UILabel = {
        let filtersLabel = UILabel()
        filtersLabel.text = "Filters:"
        filtersLabel.numberOfLines = 3
        filtersLabel.lineBreakMode = .byWordWrapping
        filtersLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        filtersLabel.font = FontProvider.Heading3.regular
        return filtersLabel
    }()

    private lazy var filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = ThemeManager.Spacing.small.rawValue
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [searchBar, filterStackView])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        view.backgroundColor = .white
        title = "E-Market"
        dataSource.delegate = self
        setupLayout()
        setupBindings()

        dataSource.onScrollReachedEnd = { [weak self] in
            guard let self = self else { return }
            self.viewModel.handleScrollReachedEnd(searchQuery: self.searchBar.text)
        }

        viewModel.fetchProducts()
    }

    // MARK: - Setup Methods

    private func setupLayout() {
        view.addSubview(headerStackView)
        view.addSubview(collectionView)
        view.addSubview(loadingContainer)
        view.addSubview(emptyStateView)

        filterStackView.addArrangedSubview(filtersLabel)

        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        filterStackView.addArrangedSubview(spacerView)
        filterStackView.addArrangedSubview(selectFilterButton)
        filterStackView.addArrangedSubview(clearFiltersButton)

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ThemeManager.Spacing.large.rawValue),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: ThemeManager.Spacing.large.rawValue),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            selectFilterButton.widthAnchor.constraint(equalToConstant: 100),
            clearFiltersButton.widthAnchor.constraint(equalToConstant: 100),

            loadingContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingIndicator.topAnchor.constraint(equalTo: loadingContainer.topAnchor, constant: ThemeManager.Spacing.large.rawValue),
            loadingIndicator.bottomAnchor.constraint(equalTo: loadingContainer.bottomAnchor, constant: -ThemeManager.Spacing.large.rawValue),
            loadingIndicator.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: ThemeManager.Spacing.large.rawValue),
            loadingIndicator.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -ThemeManager.Spacing.large.rawValue),
            
            emptyStateView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: ThemeManager.Spacing.large.rawValue),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.delegate = self
        dataSource.viewModel = viewModel
    }

    private func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 16
        let interItemSpacing: CGFloat = 16
        let numberOfItemsPerRow: CGFloat = 2

        let totalPadding = padding * (numberOfItemsPerRow + 1)
        let individualItemWidth = (view.frame.width - totalPadding) / numberOfItemsPerRow

        layout.itemSize = CGSize(width: individualItemWidth, height: 250)
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = interItemSpacing
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        return layout
    }

    private func updateFiltersDisplay() {
        var filtersText = "Filters:"

        if let sortBy = viewModel.activeSortBy, !sortBy.getDescription().isEmpty {
            filtersText += " Sort: \(sortBy.getDescription())"
        }

        if !viewModel.activeBrands.isEmpty {
            filtersText += " Brands: \(viewModel.activeBrands.joined(separator: ", "))"
        }

        if !viewModel.activeModels.isEmpty {
            filtersText += " Models: \(viewModel.activeModels.joined(separator: ", "))"
        }

        if let filtersLabel = filterStackView.arrangedSubviews.first as? UILabel {
            filtersLabel.text = filtersText
        }
    }

    // MARK: - Actions

    @objc private func filterTapped() {
        print("filter tapped")
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .overFullScreen
        present(filterVC, animated: true)
    }

    @objc private func clearFilters() {
        viewModel.clearFilters()
        viewModel.fetchProducts(reset: true)
        updateFiltersDisplay()
    }
}

// MARK: - ViewModel Delegate

extension HomeViewController: HomeViewModelDelegate {
    func didChangeEmptyState(isEmpty: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.emptyStateView.isHidden = !isEmpty
            self.collectionView.isHidden = isEmpty
        }
    }
    
    func didUpdateProducts() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
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

// MARK: - SearchBar Delegate

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.isSearchActive = false
            viewModel.fetchProducts(reset: true)
        } else {
            viewModel.isSearchActive = true
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

// MARK: - Filter Delegate

extension HomeViewController: FilterDelegate {
    func applyFilter(sortBy: SortModel?, brands: [String], models: [String]) {
        viewModel.isFilterActive = true
        viewModel.isSearchActive = false
        viewModel.fetchFilteredProducts(sortBy: sortBy, brands: brands, models: models, reset: true)
        updateFiltersDisplay()
    }
}

extension HomeViewController: HomeDataSourceDelegate {
    func didSelectProduct(_ product: ProductModel) {
        let detailVC = ProductDetailViewController()
        detailVC.product = product
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func didTapAddToCard(_ product: ProductModel) {
        if CardManager.shared.isProductInCard(productId: product.id) {
            showAlert(title: "Already Added", message: "This product is already in your Card.")
        } else {
            CardManager.shared.addToCard(productId: product.id, cardCount: 1)
            showAlert(title: "Success", message: "Product added to your card.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

