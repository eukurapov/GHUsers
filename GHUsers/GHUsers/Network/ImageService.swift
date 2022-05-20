import UIKit

protocol ImageService {
    func fetch(url: URL, completion: ((UIImage?) -> Void)?) -> Cancellable?
}

class DefaultImageService: ImageService {

    // MARK: - Properties

    // quick solution for simple cache without persistance
    private var cache: [URL: UIImage] = [:]

    // MARK: ImageService

    func fetch(url: URL, completion: ((UIImage?) -> Void)?) -> Cancellable? {
        if let image = cache[url] {
            completion?(image)
            return nil
        } else {
            let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                let image = data.flatMap { UIImage(data: $0) }
                completion?(image ?? Constants.imagePlaceholder)
                self?.cache[url] = image
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
