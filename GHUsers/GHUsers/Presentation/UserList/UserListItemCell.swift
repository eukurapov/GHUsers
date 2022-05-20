import UIKit

class UserListItemCell: UICollectionViewCell {

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

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func bind(
        with viewModel: UserListItemViewModel,
        imageService: ImageService
    ) {
        self.viewModel = viewModel

        titleLabel.text = viewModel.title
        imageView.image = Constants.imagePlaceholder

        imageLoadTask = viewModel.imageUrl.flatMap {
            imageService.fetch(url: $0) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.contentView.setNeedsLayout()
                }
                self?.imageLoadTask = nil
            }
        }
    }

    // MARK: - Private

    private func setupViews() {
        [
            imageView,
            titleLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.imageInsets.top),
            contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.imageInsets.bottom),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.imageInsets.left),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.imageInsets.right),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
}

// MARK: - Nested Types

extension UserListItemCell {
    enum Constants {
        static let imagePlaceholder = UIImage(systemName: "person")
        static let imageCornerRadius: CGFloat = 4
        static let imageInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 12)
    }
}
