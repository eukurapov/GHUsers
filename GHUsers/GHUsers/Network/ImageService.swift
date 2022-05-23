import UIKit

protocol ImageService {
    func fetch(url: URL, completion: ((UIImage?) -> Void)?) -> Cancellable?
}

class DefaultImageService: ImageService {

    // MARK: - Properties

    // quick solution for simple cache without persistance
    private var cache = NSCache<NSString, NSData>()

    // MARK: ImageService

    func fetch(url: URL, completion: ((UIImage?) -> Void)?) -> Cancellable? {
        if let imageData = cache.object(forKey: url.absoluteString as NSString),
           let image = UIImage(data: imageData as Data) {
            completion?(image)
            return nil
        } else {
            let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    completion?(Constants.imagePlaceholder)
                    return
                }
                completion?(image)
                self?.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
            }
            dataTask.resume()
            return dataTask
        }
    }
}

// MARK: - Nested Types

extension DefaultImageService {
    enum Constants {
        static let imagePlaceholder = UIImage(systemName: "person")
    }
}
