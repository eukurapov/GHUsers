import Combine
import UIKit

class UserListViewController: UICollectionViewController {

    // MARK: - Properties

    var items: [UserListItemViewModel] = []

    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: UserListViewModel?
    private let imageService: ImageService

    private lazy var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .gray
        label.text = "Could not load data"
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle

    init(
        viewModel: UserListViewModel,
        imageService: ImageService
    ) {
        self.viewModel = viewModel
        self.imageService = imageService

        let layout = UICollectionViewCompositionalLayout { _, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])
            return NSCollectionLayoutSection(group: group)
        }

        super.init(collectionViewLayout: layout)
        collectionView.prefetchDataSource = self
        collectionView.register(UserListItemCell.self, forCellWithReuseIdentifier: UserListItemCell.reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.$loading.sink { [weak self] value in
            if value == .loading && self?.items.isEmpty == true {
                self?.loader.startAnimating()
            } else {
                self?.loader.stopAnimating()
            }
            self?.errorLabel.isHidden = value != .failed
        }.store(in: &subscriptions)

        viewModel?.$listItems.sink { [weak self] value in
            self?.items = value
            self?.collectionView.reloadData()
        }.store(in: &subscriptions)

        title = "GitHub Users"

        setupViews()

        viewModel?.viewDidLoad()
    }

    // MARK: - Private

    private func setupViews() {
        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension UserListViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserListItemCell.reuseIdentifier,
            for: indexPath
        ) as? UserListItemCell else {
            assertionFailure("Could not dequeue reusable cell withIdentifier UserItemCell, for: \(indexPath)")
            return UICollectionViewCell()
        }

        cell.bind(
            with: items[indexPath.item],
            imageService: imageService
        )

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelect(item: indexPath.item)
    }
}

// MARK: - Prefetch

extension UserListViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel?.prefetch()
        }
    }
}

private extension UserListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= items.count - 1
    }
}
