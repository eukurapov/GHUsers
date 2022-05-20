import Foundation

protocol FetchUserListUseCase {
    func fetch(params: FetchUserListUseCaseParams, completion: @escaping (Result<[UserListItem],Error>) -> Void)
}

final class DefaultFetchUserListUseCase: FetchUserListUseCase {

    // MARK: - Properties

    private let userListService: UserListService

    // MARK: - Lifecycle

    init(userListService: UserListService) {
        self.userListService = userListService
    }

    // MARK: - FetchUserListUseCase

    func fetch(params: FetchUserListUseCaseParams, completion: @escaping (Result<[UserListItem], Error>) -> Void) {
        userListService.fetch(page: params.pageNumber) { result in
            completion(result)
        }
    }
}

struct FetchUserListUseCaseParams {
    let pageNumber: Int
}
