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

        title = "Feed"
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
            isExpanded: isExpanded
        )
        
        postCell.onToggleExpanded = { [weak self] in
            self?.viewModel.toggleExpanded(postId: item.postId)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        
        return postCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PostListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let item = viewModel.items[indexPath.item]
        let isExpanded = viewModel.isExpanded(postId: item.postId)
        
        // Base height for title, likes, button, and padding
        let baseHeight: CGFloat = 80
        
        // Calculate text height
        let textWidth = width - 24 // Account for cell padding
        let titleHeight = heightForText(item.title, font: .preferredFont(forTextStyle: .headline), width: textWidth)
        let previewTextHeight = heightForText(item.previewText, font: .preferredFont(forTextStyle: .body), width: textWidth, numberOfLines: isExpanded ? 0 : 2)
        
        let totalHeight = baseHeight + titleHeight + previewTextHeight + 20 // Extra spacing
        
        return CGSize(width: width, height: max(120, totalHeight)) // Minimum height of 120
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
