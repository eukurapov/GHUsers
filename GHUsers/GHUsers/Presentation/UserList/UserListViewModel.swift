import Foundation

struct UserListActions {
    let selectUser: ((UserListItem) -> Void)?
}

enum Loading {
    case loading, success, failed
}

final class UserListViewModel {

    // MARK: - Properties

    @Published var listItems: [UserListItemViewModel] = []
    @Published var loading: Loading = .success

    private var isLoading: Bool {
        loading == .loading
    }

    private let fetchUsersUseCase: FetchUserListUseCase
    private let actions: UserListActions

    private var currentPage = 0
    private var users: [UserListItem] = []

    // MARK: - Lifecycle

    init(
        fetchUsersUseCase: FetchUserListUseCase,
        actions: UserListActions
    ) {
        self.fetchUsersUseCase = fetchUsersUseCase
        self.actions = actions
    }

    // MARK: - Public

    func viewDidLoad() {
        fetchNext()
    }

    func prefetch() {
        guard !isLoading else { return }

        fetchNext()
    }

    func didSelect(item index: Int) {
        guard index < users.count else { return }

        actions.selectUser?(users[index])
    }

    // MARK: - Private

    func fetchNext() {
        loading = .loading
        let params = FetchUserListUseCaseParams(pageNumber: currentPage + 1)
        fetchUsersUseCase.fetch(params: params) { [weak self] result in
            switch result {
            case let .success(users):
                self?.users.append(contentsOf: users)
                self?.listItems.append(contentsOf: users.map(UserListItemViewModel.init))
                self?.currentPage += 1
                self?.loading = .success
            case .failure(_):
                self?.loading = .failed
            }
        }
    }
}

struct UserListItemViewModel {
    let title: String
    let imageUrl: URL?

    init(user: UserListItem) {
        title = user.login
        imageUrl = user.avatarUrl
    }
}
