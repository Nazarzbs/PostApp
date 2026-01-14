//
//  NetworkService.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()

    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        let urlString = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/main.json"
        performRequest(urlString: urlString) { (result: Result<PostListResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchPostDetail(id: Int, completion: @escaping (Result<PostDetail, Error>) -> Void) {
        let urlString = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/posts/\(id).json"
        performRequest(urlString: urlString) { (result: Result<PostDetailResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.post))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func performRequest<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }

        print("[NetworkService] Request: \(url.absoluteString)")

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                print("[NetworkService] Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                print("[NetworkService] Error: empty response data")
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            print("[NetworkService] Received bytes: \(data.count)")

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(T.self, from: data)

                print("[NetworkService] Decoded type: \(T.self)")

                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                print("[NetworkService] Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
