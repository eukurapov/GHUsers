import Foundation
import UIKit

final class UserListItemCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = String(describing: UserListItemCell.self)

    private var viewModel: UserListItemViewModel? {
        willSet {
            imageLoadTask?.cancel()
        }
    }

    private var imageLoadTask: Cancellable? {
        willSet {
            imageLoadTask?.cancel()
        }
    }

    // MARK: - Public

    func bind(
        with viewModel: UserListItemViewModel,
        imageService: ImageService
    ) {
        self.viewModel = viewModel
        selectionStyle = .none

        textLabel?.text = viewModel.title
        imageView?.image = Constants.imagePlaceholder

        imageLoadTask = viewModel.imageUrl.flatMap {
            imageService.fetch(url: $0) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView?.image = image
                    self?.setNeedsLayout()
                }
                self?.imageLoadTask = nil
            }
        }
    }
}

// MARK: - Nested Types

extension UserListItemCell {
    enum Constants {
        static let imagePlaceholder = UIImage(systemName: "person")
    }
}
