//
//  BasketViewController.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

class BasketViewController: UIViewController {
    private let viewModel = BasketViewModel()

    private lazy var loadingContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.layer.cornerRadius = ThemeManager.CornerRadius.medium.rawValue
        container.clipsToBounds = true
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

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: "cart"))
        imageView.tintColor = ThemeManager.primaryColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Your basket is empty"
        label.font = FontProvider.Body1.medium
        label.textColor = ThemeManager.primaryTextColor
        label.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Items you add to your basket will appear here"
        descriptionLabel.font = FontProvider.Body2.regular
        descriptionLabel.textColor = ThemeManager.secondaryTextColor
        descriptionLabel.textAlignment = .center

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(descriptionLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BasketCell.self, forCellReuseIdentifier: BasketCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body1.regular
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Complete", for: .normal)
        button.backgroundColor = ThemeManager.primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = ThemeManager.CornerRadius.small.rawValue
        button.titleLabel?.font = FontProvider.Body1.bold
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(completePurchase), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadBasketProducts()
        title = "Basket"
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(totalLabel)
        view.addSubview(completeButton)
        view.addSubview(loadingContainer)

        updateTotalLabel()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -ThemeManager.Spacing.large.rawValue),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ThemeManager.Spacing.large.rawValue),
            totalLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ThemeManager.Spacing.large.rawValue),

            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ThemeManager.Spacing.large.rawValue),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ThemeManager.Spacing.large.rawValue),
            completeButton.widthAnchor.constraint(equalToConstant: 120),
            completeButton.heightAnchor.constraint(equalToConstant: 44),

            loadingContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingIndicator.topAnchor.constraint(equalTo: loadingContainer.topAnchor, constant: ThemeManager.Spacing.large.rawValue),
            loadingIndicator.bottomAnchor.constraint(equalTo: loadingContainer.bottomAnchor, constant: -ThemeManager.Spacing.large.rawValue),
            loadingIndicator.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: ThemeManager.Spacing.large.rawValue),
            loadingIndicator.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -ThemeManager.Spacing.large.rawValue)
        ])
    }

    private func setupBindings() {
        viewModel.onProductsUpdated = { [weak self] in
            guard let self = self else { return }
            self.updateUI()
        }
        viewModel.delegate = self
    }

    private func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !viewModel.products.isEmpty
        tableView.isHidden = viewModel.products.isEmpty
        updateTotalLabel()
    }

    private func updateTotalLabel() {
        let totalText = "Total:\n"
        let priceText = String(format: "%.2f ₺", viewModel.totalPrice)

        let totalAttributes: [NSAttributedString.Key: Any] = [
            .font: FontProvider.Body1.regular,
            .foregroundColor: ThemeManager.primaryColor
        ]
        let priceAttributes: [NSAttributedString.Key: Any] = [
            .font: FontProvider.Body1.regular
        ]
        let attributedString = NSMutableAttributedString(string: totalText, attributes: totalAttributes)
        let priceAttributedString = NSAttributedString(string: priceText, attributes: priceAttributes)
        attributedString.append(priceAttributedString)
        totalLabel.attributedText = attributedString
    }

    @objc private func completePurchase() {
        showAlert(title: "Purchase completed", message: "Your purchase of \(String(format: "%.2f ₺", viewModel.totalPrice)) TL has been successfully completed")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate

extension BasketViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BasketCell.identifier, for: indexPath) as? BasketCell else {
            return UITableViewCell()
        }
        let product = viewModel.products[indexPath.row]
        let count = viewModel.basketCounts[product.id] ?? 0
        
        cell.configure(with: product, count: count)
        
        let productId = product.id
        cell.onIncrease = { [weak self] _ in
            self?.viewModel.increaseProductCount(for: productId)
        }
        
        cell.onDecrease = { [weak self] _ in
            self?.viewModel.decreaseProductCount(for: productId)
        }
        
        return cell
    }
}

// MARK: - BasketViewModelDelegate
extension BasketViewController: BasketViewModelDelegate {
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

// MARK: - BasketViewModel
extension BasketViewModel {
    var hasNoProducts: Bool {
        return products.isEmpty
    }
}
