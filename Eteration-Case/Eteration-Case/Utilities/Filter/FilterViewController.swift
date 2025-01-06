//
//  FilterViewController.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func applyFilter(sortBy: SortModel?, brands: [String], models: [String])
}

class FilterViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Properties
    weak var delegate: FilterDelegate?
    private let viewModel = FilterViewModel()

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter"
        label.font = FontManager.Heading1.regular
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let sortStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = ThemeManager.Spacing.large.rawValue
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let sortByLabel: UILabel = {
        let label = UILabel()
        label.text = "Sort By"
        label.font = FontManager.Heading3.medium
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "Brand"
        label.font = FontManager.Heading3.medium
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let brandSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Brand"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var brandCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.tag = 0
        collectionView.isScrollEnabled = true
        return collectionView
    }()

    private let modelLabel: UILabel = {
        let label = UILabel()
        label.text = "Model"
        label.font = FontManager.Heading3.medium
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let modelSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Model"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var modelCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.tag = 1
        collectionView.isScrollEnabled = true
        return collectionView
    }()

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply", for: .normal)
        button.backgroundColor = ThemeManager.primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = ThemeManager.CornerRadius.medium.rawValue
        button.titleLabel?.font = FontManager.Body1.semibold
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupCollectionViews()
        bindViewModel()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(sortByLabel)
        containerView.addSubview(sortStackView)
        containerView.addSubview(brandLabel)
        containerView.addSubview(brandSearchBar)
        containerView.addSubview(brandCollectionView)
        containerView.addSubview(modelLabel)
        containerView.addSubview(modelSearchBar)
        containerView.addSubview(modelCollectionView)
        
        view.addSubview(applyButton)
        
        viewModel.sortOptions.forEach { option in
            let radioButton = createRadioButton(title: option.getDescription())
            sortStackView.addArrangedSubview(radioButton)
        }
        
        setupConstraints()
    }

    private func setupConstraints() {
        let padding: CGFloat = ThemeManager.Spacing.large.rawValue
        
        NSLayoutConstraint.activate([
            // Header view constraints
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: padding),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -padding),
            
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Sort section
            sortByLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            sortByLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            sortByLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            
            sortStackView.topAnchor.constraint(equalTo: sortByLabel.bottomAnchor, constant: padding),
            sortStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            sortStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            
            // Brand section
            brandLabel.topAnchor.constraint(equalTo: sortStackView.bottomAnchor, constant: padding * 2),
            brandLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            
            brandSearchBar.topAnchor.constraint(equalTo: brandLabel.bottomAnchor),
            brandSearchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            brandSearchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            brandCollectionView.topAnchor.constraint(equalTo: brandSearchBar.bottomAnchor, constant: padding),
            brandCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            brandCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            brandCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            // Model section
            modelLabel.topAnchor.constraint(equalTo: brandCollectionView.bottomAnchor, constant: padding * 2),
            modelLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            
            modelSearchBar.topAnchor.constraint(equalTo: modelLabel.bottomAnchor),
            modelSearchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            modelSearchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            modelCollectionView.topAnchor.constraint(equalTo: modelSearchBar.bottomAnchor, constant: padding),
            modelCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            modelCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            modelCollectionView.heightAnchor.constraint(equalToConstant: 150),
            modelCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            
            // Apply button constraints
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        brandSearchBar.delegate = self
        modelSearchBar.delegate = self
    }

    private func setupCollectionViews() {
        brandCollectionView.delegate = self
        brandCollectionView.dataSource = self
        brandCollectionView.register(FilterOptionCell.self, forCellWithReuseIdentifier: FilterOptionCell.identifier)

        modelCollectionView.delegate = self
        modelCollectionView.dataSource = self
        modelCollectionView.register(FilterOptionCell.self, forCellWithReuseIdentifier: FilterOptionCell.identifier)
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.brandCollectionView.reloadData()
            self.modelCollectionView.reloadData()
        }
    }

    private func createRadioButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "circle.fill"), for: .selected)
        button.setTitle("  \(title)", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = FontManager.Body1.regular
        button.tintColor = ThemeManager.primaryColor
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func applyButtonTapped() {
        delegate?.applyFilter(sortBy: viewModel.selectedSortOption, brands: Array(viewModel.selectedBrands), models: Array(viewModel.selectedModels))
        dismiss(animated: true, completion: nil)
    }

    @objc private func radioButtonTapped(_ sender: UIButton) {
        sortStackView.arrangedSubviews.forEach { view in
            guard let button = view as? UIButton else { return }
            button.isSelected = button == sender
        }
        viewModel.selectSortOption(sender.title(for: .normal)?.trimmingCharacters(in: .whitespaces) ?? "")
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = ThemeManager.Spacing.small.rawValue

        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource
extension FilterViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == brandCollectionView {
            return viewModel.filteredBrandOptions.count
        } else {
            return viewModel.filteredModelOptions.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterOptionCell.identifier, for: indexPath) as? FilterOptionCell else {
            return UICollectionViewCell()
        }

        let title = collectionView == brandCollectionView ? viewModel.filteredBrandOptions[indexPath.item] : viewModel.filteredModelOptions[indexPath.item]
        let isSelected = collectionView == brandCollectionView ? viewModel.selectedBrands.contains(title) : viewModel.selectedModels.contains(title)

        cell.configure(with: title, isSelected: isSelected) { [weak self] tappedTitle, isSelected in
            guard let self = self else { return }
            if collectionView == brandCollectionView {
                self.viewModel.toggleBrandSelection(tappedTitle)
            } else {
                self.viewModel.toggleModelSelection(tappedTitle)
            }
        }
        return cell
    }

    // MARK: - UISearchBarDelegate

      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchBar == brandSearchBar {
              viewModel.searchBrands(with: searchText)
          } else if searchBar == modelSearchBar {
              viewModel.searchModels(with: searchText)
          }
      }
}
