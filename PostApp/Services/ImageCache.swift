//
//  ImageCache.swift
//  PostApp
//
//  Created by Nazar on 14.01.2026.
//

import UIKit
import Foundation

actor ImageCache {
    
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        Task {
            await createCacheDirectoryIfNeeded()
        }
    }
    
    private func createCacheDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("Failed to create cache directory: \(error)")
        }
    }
    
    func image(from urlString: String) async throws -> UIImage {
        
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        let diskCacheKey = diskCacheKey(for: urlString)
        let diskCacheURL = cacheDirectory.appendingPathComponent(diskCacheKey)
        
        if fileManager.fileExists(atPath: diskCacheURL.path),
           let diskImageData = try? Data(contentsOf: diskCacheURL),
           let diskImage = UIImage(data: diskImageData) {
            // Store in memory cache
            cache.setObject(diskImage, forKey: urlString as NSString, cost: diskImageData.count)
            return diskImage
        }
        
        guard let url = URL(string: urlString) else {
            throw ImageCacheError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw ImageCacheError.invalidImageData
        }
        
        cache.setObject(image, forKey: urlString as NSString, cost: data.count)
        
        do {
            try data.write(to: diskCacheURL)
        } catch {
            print("Failed to cache image on disk: \(error)")
        }
        
        return image
    }
    
    private func diskCacheKey(for urlString: String) -> String {
        return urlString.data(using: .utf8)?.base64EncodedString() ?? urlString
    }
}

enum ImageCacheError: Error {
    case invalidURL
    case invalidImageData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .invalidImageData:
            return "Invalid image data"
        }
    }
}
