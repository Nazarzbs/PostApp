//
//  PostItem.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import Foundation

struct PostItem: Hashable, Sendable {
    let postId: Int
    let title: String
    let previewText: String
    let likesCount: Int
}
