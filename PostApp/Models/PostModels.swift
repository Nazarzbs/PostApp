//
//  PostModels.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import Foundation

struct PostListResponse: Codable, Sendable {
    let posts: [Post]
}

struct Post: Codable, Hashable, Sendable {
    let postId: Int
    let timeshamp: TimeInterval
    let title: String
    let previewText: String
    let likesCount: Int

    var isExpanded: Bool = false

    enum CodingKeys: String, CodingKey {
        case postId
        case timeshamp
        case title
        case previewText
        case likesCount
    }
}

struct PostDetailResponse: Codable {
    let post: PostDetail
}

struct PostDetail: Codable, Sendable {
    let postId: Int
    let timeshamp: TimeInterval
    let title: String
    let text: String
    let postImage: String
    let likesCount: Int
}
