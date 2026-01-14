//
//  ViewController.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkService.shared.fetchPosts { result in
            switch result {
            case .success(let posts):
                print("Posts count: \(posts.count)")

                if let first = posts.first {
                    print("First post id: \(first.postId)")
                    print("First post title: \(first.title)")
                    print("First post likes: \(first.likesCount)")

                    NetworkService.shared.fetchPostDetail(id: first.postId) { detailResult in
                        switch detailResult {
                        case .success(let detail):
                            print("Detail id: \(detail.postId)")
                            print("Detail title: \(detail.title)")
                            print("Detail likes: \(detail.likesCount)")
                            print("Detail image: \(detail.postImage)")
                        case .failure(let error):
                            print("Detail error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("Posts error: \(error)")
            }
        }
    }
}

