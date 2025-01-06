//
//  FavoritesViewController.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

class FavoritesViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = FavoritesViewModel()

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: "heart.slash"))
        imageView.tintColor = ThemeManager.primaryColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "No favorites yet"
        label.font = FontManager.Body1.medium
        label.textColor = ThemeManager.primaryTextColor
        label.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Items you favorite will appear here"
        descriptionLabel.font = FontManager.Body2.regular
        descriptionLabel.textColor = ThemeManager.secondaryTextColor
        descriptionLabel.textAlignment = .center

        let exploreButton = UIButton(type: .system)
        exploreButton.setTitle("Explore Products", for: .normal)
        exploreButton.setTitleColor(ThemeManager.primaryColor, for: .normal)
        exploreButton.titleLabel?.font = FontManager.Body1.bold
        exploreButton.addTarget(self, action: #selector(exploreButtonTapped), for: .touchUpInside)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(exploreButton)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    private lazy var loadingContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isHidden = true

        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.startAnimating()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
        setupNotificationObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = ThemeManager.backgroundColor

        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingContainer)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingContainer.topAnchor.constraint(equalTo: view.topAnchor),
            loadingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {
        title = "Favorites"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }

    private func bindViewModel() {
        viewModel.onProductsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.loadingContainer.isHidden = !isLoading
            }
        }
    }

    private func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !viewModel.hasNoFavorites
        tableView.isHidden = viewModel.hasNoFavorites
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoritesUpdated),
            name: .favoritesUpdated,
            object: nil
        )
    }

    // MARK: - Actions
    @objc private func handleFavoritesUpdated() {
        viewModel.loadFavorites()
    }

    @objc private func editButtonTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }

    @objc private func exploreButtonTapped() {
        tabBarController?.selectedIndex = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }

        let product = viewModel.products[indexPath.row]
        cell.configure(with: product)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = viewModel.products[indexPath.row]
            FavoriteManager.shared.removeFromFavorites(productId: product.id)
            viewModel.loadFavorites()
        }
    }
}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let product = viewModel.products[indexPath.row]
        let detailVC = ProductDetailViewController()
        detailVC.product = product
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
