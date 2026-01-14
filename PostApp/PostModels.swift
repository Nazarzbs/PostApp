//
//  PostModels.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import Foundation

struct PostListResponse: Codable {
    let posts: [Post]
}

struct Post: Codable {
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

struct PostDetail: Codable {
    let postId: Int
    let timeshamp: TimeInterval
    let title: String
    let text: String
    let postImage: String
    let likesCount: Int
}
