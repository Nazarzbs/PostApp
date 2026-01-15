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
    private let dateLabel = UILabel()
    private let expandButton = UIButton(type: .system)
    
    private let textStackView = UIStackView()
    private let metaStackView = UIStackView()
    private let rootStackView = UIStackView()
    
    var onToggleExpanded: (() -> Void)?

    func isPointInsideExpandButton(_ point: CGPoint) -> Bool {
        guard !expandButton.isHidden, expandButton.alpha > 0, expandButton.isUserInteractionEnabled else {
            return false
        }
        let buttonFrameInContentView = expandButton.convert(expandButton.bounds, to: contentView)
        return buttonFrameInContentView.contains(point)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupButtonAction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
        setupButtonAction()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onToggleExpanded = nil
        expandButton.isHighlighted = false
        expandButton.isSelected = false
        
        expandButton.isHidden = true
        expandButton.configuration = nil
        
        titleLabel.text = nil
        previewLabel.text = nil
        likesLabel.text = nil
        dateLabel.text = nil
    }
    
    func configure(title: String, previewText: String, likesCount: Int, timestamp: TimeInterval, isExpanded: Bool) {
        titleLabel.text = title
        previewLabel.text = previewText
        likesLabel.text = "❤️ \(likesCount)"
        
        let timeAgo = formatTimeAgo(from: timestamp)
        dateLabel.text = "📅 \(timeAgo)"
        
        previewLabel.numberOfLines = isExpanded ? 0 : 2
        
        let needsExpandButton = textNeedsExpandButton(text: previewText)
        expandButton.isHidden = !needsExpandButton
        
        if needsExpandButton {
            let buttonImage = isExpanded ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            let buttonTitle = isExpanded ? "Collapse" : "Expand"
            
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .systemBlue.withAlphaComponent(0.1)
            config.baseForegroundColor = .systemBlue
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            config.imagePlacement = .trailing
            config.imagePadding = 8
            config.image = buttonImage
            config.title = buttonTitle
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = .preferredFont(forTextStyle: .callout)
                return out
            }
            expandButton.configuration = config
        }
    }
    
    private func textNeedsExpandButton(text: String) -> Bool {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        
        let availableWidth = UIScreen.main.bounds.width - 48
        
        let constrainedSize = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        let twoLineSize = label.sizeThatFits(constrainedSize)
        
        label.numberOfLines = 0
        let fullSize = label.sizeThatFits(constrainedSize)
        
        return fullSize.height > twoLineSize.height + 1 // +1 for rounding errors
    }
    
    private func formatTimeAgo(from timestamp: TimeInterval) -> String {
        let now = Date()
        let postDate = Date(timeIntervalSince1970: timestamp)
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: postDate, to: now)
        
        if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
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
        likesLabel.textColor = .systemBlue
        
        dateLabel.font = .preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue.withAlphaComponent(0.1)
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .preferredFont(forTextStyle: .callout)
            return out
        }
        expandButton.configuration = config
        expandButton.isExclusiveTouch = true
        
        textStackView.axis = .vertical
        textStackView.spacing = 6
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(previewLabel)
        
        metaStackView.axis = .horizontal
        metaStackView.spacing = 8
        metaStackView.translatesAutoresizingMaskIntoConstraints = false
        metaStackView.addArrangedSubview(likesLabel)
        metaStackView.addArrangedSubview(UIView()) // Spacer
        metaStackView.addArrangedSubview(dateLabel)
        
        rootStackView.axis = .vertical
        rootStackView.spacing = 10
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.addArrangedSubview(textStackView)
        rootStackView.addArrangedSubview(metaStackView)
        rootStackView.addArrangedSubview(expandButton)
        
        contentView.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        expandButton.setContentHuggingPriority(.required, for: .vertical)
        expandButton.isUserInteractionEnabled = true
    }
    
    private func setupButtonAction() {
        expandButton.addAction(UIAction { [weak self] _ in
            self?.expandButton.isHighlighted = false
            self?.expandButton.isSelected = false
            self?.onToggleExpanded?()
        }, for: .touchUpInside)
        
        expandButton.isUserInteractionEnabled = true
    }
}

