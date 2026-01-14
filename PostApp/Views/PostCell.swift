//
//  PostCell.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import UIKit

final class PostCell: UICollectionViewCell {

    static let reuseIdentifier = "PostCell"

    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    private let likesLabel = UILabel()
    private let expandButton = UIButton(type: .system)

    private let textStackView = UIStackView()
    private let rootStackView = UIStackView()

    var onToggleExpanded: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggleExpanded = nil
    }

    func configure(title: String, previewText: String, likesCount: Int, isExpanded: Bool) {
        titleLabel.text = title
        previewLabel.text = previewText
        likesLabel.text = "Likes: \(likesCount)"

        previewLabel.numberOfLines = isExpanded ? 0 : 2
        expandButton.setTitle(isExpanded ? "Collapse" : "Expand", for: .normal)
    }

    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0

        previewLabel.font = .preferredFont(forTextStyle: .body)
        previewLabel.textColor = .secondaryLabel
        previewLabel.numberOfLines = 2

        likesLabel.font = .preferredFont(forTextStyle: .caption1)
        likesLabel.textColor = .tertiaryLabel

        expandButton.addAction(UIAction { [weak self] _ in
            self?.onToggleExpanded?()
        }, for: .touchUpInside)

        textStackView.axis = .vertical
        textStackView.spacing = 6
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(previewLabel)
        textStackView.addArrangedSubview(likesLabel)

        rootStackView.axis = .vertical
        rootStackView.spacing = 10
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.addArrangedSubview(textStackView)
        rootStackView.addArrangedSubview(expandButton)

        contentView.addSubview(rootStackView)

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        expandButton.setContentHuggingPriority(.required, for: .vertical)
    }
}
