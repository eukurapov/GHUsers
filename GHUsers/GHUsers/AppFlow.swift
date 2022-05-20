import Foundation
import UIKit

struct AppDependencies {
    let userListFlowDependencies: UserListFlowDependencies
}

final class AppFlow {

    // MARK: - Properties

    private let navigationController: UINavigationController
    private let dependencies: AppDependencies
    private var userListFlow: UserListFlow?
    

    // MARK: - Lifecycle

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: Public

    func start() {
        userListFlow = UserListFlow(
            navigationController: navigationController,
            dependencies: dependencies.userListFlowDependencies
        )
        userListFlow?.start()
    }
}
