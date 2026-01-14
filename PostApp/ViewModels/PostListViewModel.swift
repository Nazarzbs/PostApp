//
//  PostListViewModel.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import Foundation

@MainActor
final class PostListViewModel {

    private(set) var items: [PostItem] = []
    private var expandedPostIds: Set<Int> = []

    var onChange: (() -> Void)?
    var onError: ((Error) -> Void)?

    func load() {
        Task {
            do {
                let posts = try await NetworkService.shared.fetchPosts()
                self.items = posts.map {
                    PostItem(
                        postId: $0.postId,
                        title: $0.title,
                        previewText: $0.previewText,
                        likesCount: $0.likesCount
                    )
                }
                self.onChange?()
            } catch {
                self.onError?(error)
            }
        }
    }

    func isExpanded(postId: Int) -> Bool {
        expandedPostIds.contains(postId)
    }

    func toggleExpanded(postId: Int) {
        if expandedPostIds.contains(postId) {
            expandedPostIds.remove(postId)
        } else {
            expandedPostIds.insert(postId)
        }
        onChange?()
    }
}
