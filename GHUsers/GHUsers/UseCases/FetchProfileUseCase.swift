import Foundation

protocol FetchUserProfileUseCase {
    func fetch(params: FetchProfileUseCaseParams, completion: @escaping (Result<[User],Error>) -> Void)
}

final class DefaultFetchProfileUseCase: FetchUserProfileUseCase {

    // MARK: - Properties

    private let usersService: UsersService

    // MARK: - Lifecycle

    init(usersService: UsersService) {
        self.usersService = usersService
    }

    // MARK: - FetchUsersUseCase

    func fetch(params: FetchProfileUseCaseParams, completion: @escaping (Result<[User], Error>) -> Void) {
        usersService.fetchProfile(login: params.login) { result in
            completion(result)
        }
    }
}

struct FetchProfileUseCaseParams {
    let login: String
}
