import Combine
import UIKit

class UserProfileViewController: UIViewController {

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: UserProfileViewModel?
    private var imageService: ImageService

    private var imageLoadTask: Cancellable? {
        willSet {
            imageLoadTask?.cancel()
        }
    }

    private var scrollView = UIScrollView()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.layer.masksToBounds = true
        imageView.image = Constants.imagePlaceholder
        return imageView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Constants.stackViewSpacing
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private lazy var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        return indicator
    }()

    // MARK: - Lifecycle

    init(
        viewModel: UserProfileViewModel,
        imageService: ImageService
    ) {
        self.viewModel = viewModel
        self.imageService = imageService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel?.login

        setupSubscriptions()
        setupViews()
        viewModel?.viewDidLoad()
    }

    // MARK: - Private

    private func setupSubscriptions() {
        viewModel?.$loading.sink { [weak self] value in
            if value == true {
                self?.loader.startAnimating()
            } else {
                self?.loader.stopAnimating()
            }
        }.store(in: &subscriptions)

        viewModel?.$name.sink { [weak self] value in
            self?.nameLabel.text = value
            self?.nameLabel.isHidden = value == nil
        }.store(in: &subscriptions)

        viewModel?.$email.sink { [weak self] value in
            self?.emailLabel.text = value
            self?.emailLabel.isHidden = value == nil
        }.store(in: &subscriptions)

        viewModel?.$avatarUrl.sink { [weak self] value in
            self?.setAvatarImage(url: value)
        }.store(in: &subscriptions)

        viewModel?.$location.sink { [weak self] value in
            self?.locationLabel.text = value
            self?.locationLabel.isHidden = value == nil
        }.store(in: &subscriptions)

        viewModel?.$bio.sink { [weak self] value in
            self?.bioLabel.text = value
            self?.bioLabel.isHidden = value == nil
        }.store(in: &subscriptions)
    }

    private func setupViews() {
        [
            scrollView,
            avatarImageView,
            stackView,
            loader
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        view.addSubview(scrollView)
        view.addSubview(loader)
        scrollView.addSubview(avatarImageView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(bioLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),

            avatarImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.imageInsets.top),
            avatarImageView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.imageInsets.right
            ),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: Constants.imageInsets.left
            ),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.imageInsets.bottom),
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.stackViewInsets.right
            ),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor,
                constant: Constants.stackViewInsets.left
            ),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),

            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setAvatarImage(url: URL?) {
        avatarImageView.image = Constants.imagePlaceholder

        imageLoadTask = url.flatMap {
            imageService.fetch(url: $0) { [weak self] image in
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                    self?.avatarImageView.setNeedsLayout()
                }
                self?.imageLoadTask = nil
            }
        }
    }
}

// MARK: - Nested Types

extension UserProfileViewController {
    enum Constants {
        static let imageCornerRadius: CGFloat = 7
        static let imageInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let imagePlaceholder = UIImage(systemName: "person")

        static let stackViewSpacing: CGFloat = 8
        static let stackViewInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
