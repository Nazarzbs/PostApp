//
//  NetworkService.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import Foundation

final class NetworkService: Sendable {
    static let shared = NetworkService()
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPosts() async throws -> [Post] {
        let urlString = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/main.json"
        let response: PostListResponse = try await performRequest(urlString: urlString)
        return response.posts
    }
    
    func fetchPostDetail(id: Int) async throws -> PostDetail {
        let urlString = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/posts/\(id).json"
        let response: PostDetailResponse = try await performRequest(urlString: urlString)
        return response.post
    }

    private func performRequest<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
