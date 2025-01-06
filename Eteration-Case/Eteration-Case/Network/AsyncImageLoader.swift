//
//  AsyncImageLoader.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import UIKit
import Foundation

class ImageLoadOperation: Operation {
    let url: URL
    var downloadedImage: UIImage?
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            downloadedImage = image
        }
    }
}

class AsyncImageLoader {
    static let shared = AsyncImageLoader()
    private let operationQueue = OperationQueue()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        operationQueue.maxConcurrentOperationCount = 3
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> Operation? {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return nil
        }
        
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return nil
        }
        
        let operation = ImageLoadOperation(url: url)
        
        operation.completionBlock = { [weak self] in
            guard let downloadedImage = operation.downloadedImage,
                  !operation.isCancelled else {
                return
            }
            
            self?.cache.setObject(downloadedImage, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        
        operationQueue.addOperation(operation)
        return operation
    }
    
    func cancelAllOperations() {
        operationQueue.cancelAllOperations()
    }
}
