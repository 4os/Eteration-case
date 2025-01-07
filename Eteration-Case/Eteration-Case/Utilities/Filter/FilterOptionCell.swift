//
//  FilterOptionCell.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit

// MARK: - FilterOptionCell
class FilterOptionCell: UICollectionViewCell {
    static let identifier = "FilterOptionCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontProvider.Body1.regular
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square")
        imageView.tintColor = ThemeManager.primaryColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var onTap: ((String, Bool) -> Void)?
    private var title: String = ""
    private var isSelectedItem: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(checkboxImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            checkboxImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.widthAnchor.constraint(equalToConstant: 24),
            checkboxImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: checkboxImageView.trailingAnchor, constant: ThemeManager.Spacing.small.rawValue),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String, isSelected: Bool, onTap: @escaping (String, Bool) -> Void) {
        self.title = title
        self.isSelectedItem = isSelected
        self.onTap = onTap

        titleLabel.text = title
        checkboxImageView.image = UIImage(systemName: isSelected ? "checkmark.square" : "square")
    }

    @objc private func handleTap() {
        isSelectedItem.toggle()
        checkboxImageView.image = UIImage(systemName: isSelectedItem ? "checkmark.square" : "square")
        onTap?(title, isSelectedItem)
    }
}
