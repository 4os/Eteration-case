//
//  AsyncImageLoader.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//
import UIKit
import Foundation

/// Operation for downloading an image from a URL
class ImageLoadOperation: Operation {
    let url: URL
    var downloadedImage: UIImage?
    
    /// - Parameter url: The URL to download the image from
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    /// Main method where the image download is performed
    override func main() {
        // Ensure the operation has not been cancelled before proceeding
        guard !isCancelled else { return }
        
        // Attempt to download and decode the image
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            downloadedImage = image
        }
    }
}

/// Singleton class for asynchronously loading images
class AsyncImageLoader {
    static let shared = AsyncImageLoader()
    private let operationQueue = OperationQueue()
    private let cache = NSCache<NSString, UIImage>()
    private init() {
        operationQueue.maxConcurrentOperationCount = 3
    }
    
    /// - Parameters:
    ///   - urlString: The URL string of the image
    ///   - completion: Completion handler to return the downloaded image
    /// - Returns: The created operation, if any
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> Operation? {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return nil
        }
        
        // Check if the image is already cached
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
            
            // Cache the downloaded image
            self?.cache.setObject(downloadedImage, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        
        // Add the operation to the queue
        operationQueue.addOperation(operation)
        return operation
    }
    
    /// Cancels all ongoing operations
    func cancelAllOperations() {
        operationQueue.cancelAllOperations()
    }
}
