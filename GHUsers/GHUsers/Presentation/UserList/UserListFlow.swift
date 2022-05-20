import Foundation
import UIKit

struct UserListFlowDependencies {
    let userListService: UserListService
    let userProfileService: UserProfileService
    let imageService: ImageService
}

final class UserListFlow {

    // MARK: - Properties

    private weak var navigationController: UINavigationController?
    private var dependencies: UserListFlowDependencies

    // MARK: - Lifecycle

    init(
        navigationController: UINavigationController,
        dependencies: UserListFlowDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: Public

    func start() {
        let actions = UserListActions(selectUser: showUserProfile)
        let viewController = UserListViewController(
            viewModel: UserListViewModel(
                fetchUsersUseCase: DefaultFetchUserListUseCase(userListService: dependencies.userListService),
                actions: actions
            ),
            imageService: dependencies.imageService
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Private

    private func showUserProfile(_ userItem: UserListItem) {
        let userProfileUseCase = DefaultFetchUserProfileUseCase(userProfileService: dependencies.userProfileService)
        let viewController = UserProfileViewController(
            viewModel: UserProfileViewModel(
                login: userItem.login,
                fetchUserProfileUseCase: userProfileUseCase
            ),
            imageService: dependencies.imageService
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
}
