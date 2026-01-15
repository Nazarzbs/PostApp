//
//  PostListViewController.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import UIKit

final class PostListViewController: UIViewController {

    private let viewModel = PostListViewModel()

    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Post Feed"
        view.backgroundColor = .systemBackground

        configureCollectionView()
        bindViewModel()
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.collectionView.reloadData()
        }

        viewModel.onError = { error in
            print("PostList error: \(error)")
        }
    }

    private func configureCollectionView() {
        let layout = makeLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(PostCell.self, forCellWithReuseIdentifier: PostCell.reuseIdentifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return layout
    }
}

// MARK: - UICollectionViewDataSource
extension PostListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath)
        
        guard let postCell = cell as? PostCell else {
            return cell
        }
        
        let item = viewModel.items[indexPath.item]
        let isExpanded = viewModel.isExpanded(postId: item.postId)
        
        postCell.configure(
            title: item.title,
            previewText: item.previewText,
            likesCount: item.likesCount,
            timestamp: item.timestamp,
            isExpanded: isExpanded
        )
        
        postCell.onToggleExpanded = { [weak self] in
            guard let self = self else { return }
            self.viewModel.toggleExpanded(postId: item.postId)

            self.collectionView.performBatchUpdates({
                if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    let context = UICollectionViewFlowLayoutInvalidationContext()
                    context.invalidateItems(at: [indexPath])
                    layout.invalidateLayout(with: context)
                } else {
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }
            })
        }
        
        return postCell
    }
}

extension PostListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.item]
        let detailsViewController = PostDetailsViewController(postId: item.postId)
        
        navigationController?.pushViewController(detailsViewController, animated: true)
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension PostListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let item = viewModel.items[indexPath.item]
        let isExpanded = viewModel.isExpanded(postId: item.postId)

        let baseHeight: CGFloat = 60

        let textWidth = width - 24
        let titleHeight = heightForText(item.title, font: .preferredFont(forTextStyle: .headline), width: textWidth)
        let previewTextHeight = heightForText(item.previewText, font: .preferredFont(forTextStyle: .body), width: textWidth, numberOfLines: isExpanded ? 0 : 2)

        let needsExpandButton = textNeedsExpandButton(text: item.previewText, width: textWidth)
        let expandButtonHeight: CGFloat = needsExpandButton ? 60 : 0

        let totalHeight = baseHeight + titleHeight + previewTextHeight + expandButtonHeight + 20

        return CGSize(width: width, height: max(120, totalHeight))
    }

    private func textNeedsExpandButton(text: String, width: CGFloat) -> Bool {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail

        let constrainedSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let twoLineSize = label.sizeThatFits(constrainedSize)

        label.numberOfLines = 0
        let fullSize = label.sizeThatFits(constrainedSize)

        return fullSize.height > twoLineSize.height + 1
    }

    private func heightForText(_ text: String, font: UIFont, width: CGFloat, numberOfLines: Int = 0) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = font
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byWordWrapping
        return label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
    }
}
