//
//  PostDetailsViewController.swift
//  PostApp
//
//  Created by Nazar on 15.01.2026.
//

import UIKit

final class PostDetailsViewController: UIViewController {
    
    private let postId: Int
    private let networkService: NetworkService
    private let imageCache: ImageCache
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
   
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let likesLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let metaStackView = UIStackView()
    private let stackView = UIStackView()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    init(postId: Int, networkService: NetworkService = NetworkService.shared, imageCache: ImageCache = ImageCache.shared) {
        self.postId = postId
        self.networkService = networkService
        self.imageCache = imageCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPostDetails()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Post Details"
        
        setupScrollView()
        setupImageView()
        setupLabels()
        setupStackView()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    private func setupLabels() {
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label
        
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.numberOfLines = 0
        textLabel.textColor = .label
        
        likesLabel.font = .preferredFont(forTextStyle: .subheadline)
        likesLabel.textColor = .systemBlue
        likesLabel.setContentHuggingPriority(.required, for: .vertical)
        
        dateLabel.font = .preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel
        dateLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    private func setupMetaStackView() {
        metaStackView.axis = .horizontal
        metaStackView.spacing = 8
        metaStackView.translatesAutoresizingMaskIntoConstraints = false

        likesLabel.textAlignment = .left
        dateLabel.textAlignment = .right

        metaStackView.addArrangedSubview(likesLabel)
        metaStackView.addArrangedSubview(UIView())
        metaStackView.addArrangedSubview(dateLabel)
    }

    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textLabel)
        setupMetaStackView()
        stackView.addArrangedSubview(metaStackView)
        
        contentView.addSubview(stackView)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
           
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadPostDetails() {
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let postDetail = try await networkService.fetchPostDetail(id: postId)
                
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.configureUI(with: postDetail)
                }
            } catch {
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func configureUI(with postDetail: PostDetail) {
        titleLabel.text = postDetail.title
        textLabel.text = postDetail.text
        likesLabel.text = "❤️ \(postDetail.likesCount) likes"
        
        let date = Date(timeIntervalSince1970: postDetail.timeshamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: date)
        
        loadImage(from: postDetail.postImage)
    }
    
    private func loadImage(from urlString: String) {
        Task {
            do {
                let image = try await imageCache.image(from: urlString)
                await MainActor.run {
                    self.imageView.image = image
                }
            } catch {
                await MainActor.run {
                    print("Failed to load image: \(error)")
                    self.imageView.image = UIImage(systemName: "photo")
                }
            }
        }
    }
}
