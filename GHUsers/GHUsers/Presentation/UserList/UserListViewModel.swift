import Foundation

struct UserListActions {
    let selectUser: ((UserListItem) -> Void)?
}

final class UserListViewModel {

    // MARK: - Properties

    @Published var listItems: [UserListItemViewModel] = []
    @Published var loading: Bool = false

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
        guard !loading else { return }

        fetchNext()
    }

    func didSelect(item index: Int) {
        guard index < users.count else { return }

        actions.selectUser?(users[index])
    }

    // MARK: - Private

    func fetchNext() {
        loading = true
        let params = FetchUserListUseCaseParams(pageNumber: currentPage + 1)
        fetchUsersUseCase.fetch(params: params) { [weak self] result in
            switch result {
            case let .success(users):
                self?.users.append(contentsOf: users)
                self?.listItems.append(contentsOf: users.map(UserListItemViewModel.init))
                self?.currentPage += 1
            case let .failure(error):
                print(error)
            }
            self?.loading = false
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
