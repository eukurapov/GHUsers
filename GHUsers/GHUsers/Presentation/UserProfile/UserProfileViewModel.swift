import Combine
import Foundation

final class UserProfileViewModel {

    // MARK: - Properties

    @Published var login: String
    @Published var name: String?
    @Published var email: String?
    @Published var location: String?
    @Published var bio: String?
    @Published var avatarUrl: URL?
    @Published var loading = false

    private var fetchUserProfileUseCase: FetchUserProfileUseCase

    // MARK: - Lifecycle

    init(login: String, fetchUserProfileUseCase: FetchUserProfileUseCase) {
        self.login = login
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
    }

    // MARK: - Public

    func viewDidLoad() {
        fetch()
    }

    // MARK: - Private

    private func fetch() {
        loading = true
        let fetchParams = FetchUserProfileUseCaseParams(login: login)
        fetchUserProfileUseCase.fetch(params: fetchParams) { [weak self] result in
            switch result {
            case let .success(profile):
                self?.configure(with: profile)
            case let .failure(error):
                print(error)
            }
            self?.loading = false
        }
    }

    private func configure(with profile: UserProfile) {
        name = profile.name
        email = profile.email
        avatarUrl = profile.avatarUrl
        location = profile.location
        bio = profile.bio
    }

}
