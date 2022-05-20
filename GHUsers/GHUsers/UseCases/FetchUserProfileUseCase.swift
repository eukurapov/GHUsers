import Foundation

protocol FetchUserProfileUseCase {
    func fetch(params: FetchUserProfileUseCaseParams, completion: @escaping (Result<UserProfile, Error>) -> Void)
}

final class DefaultFetchUserProfileUseCase: FetchUserProfileUseCase {

    // MARK: - Properties

    private let userProfileService: UserProfileService

    // MARK: - Lifecycle

    init(userProfileService: UserProfileService) {
        self.userProfileService = userProfileService
    }

    // MARK: - FetchUsersUseCase

    func fetch(params: FetchUserProfileUseCaseParams, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        userProfileService.fetchProfile(login: params.login) { result in
            completion(result)
        }
    }
}

struct FetchUserProfileUseCaseParams {
    let login: String
}
