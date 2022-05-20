import Combine
import UIKit

class UserListViewController: UITableViewController {

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

    // MARK: - Lifecycle

    init(
        viewModel: UserListViewModel,
        imageService: ImageService
    ) {
        self.viewModel = viewModel
        self.imageService = imageService

        super.init(nibName: nil, bundle: nil)

        tableView.prefetchDataSource = self
        tableView.register(UserListItemCell.self, forCellReuseIdentifier: UserListItemCell.reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.$loading.sink { [weak self] value in
            if value == true {
                self?.loader.startAnimating()
            } else {
                self?.loader.stopAnimating()
            }
        }.store(in: &subscriptions)

        viewModel?.$listItems.sink { [weak self] value in
            self?.items = value
            self?.tableView.reloadData()
        }.store(in: &subscriptions)

        title = "GitHub Users"

        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        viewModel?.viewDidLoad()
    }
}

// MARK: - UITableViewDataSource

extension UserListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UserListItemCell.reuseIdentifier,
            for: indexPath
        ) as? UserListItemCell else {
            assertionFailure("Could not dequeue reusable cell withIdentifier UserItemCell, for: \(indexPath)")
            return UITableViewCell()
        }

        cell.bind(
            with: items[indexPath.item],
            imageService: imageService
        )

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didSelect(item: indexPath.item)
    }
}

// MARK: - Prefetch

extension UserListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
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
