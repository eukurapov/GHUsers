import Foundation

class DummyUserListService: UserListService {

    func fetch(page: Int, completion: @escaping (Result<[UserListItem], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completion(Result.success([
                UserListItem(id: 1, login: "userone", avatarUrl: URL(string: "https://avatars.githubusercontent.com/u/1?v=4")),
                UserListItem(id: 2, login: "usertwo", avatarUrl: URL(string: "https://avatars.githubusercontent.com/u/2?v=4")),
                UserListItem(id: 3, login: "onemoreuser", avatarUrl: URL(string: "https://avatars.githubusercontent.com/u/3?v=4"))
            ]))
        }
    }
}

class DummyUserProfileService: UserProfileService {

    func fetchProfile(login: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completion(Result.success(
                UserProfile(id: 1, login: "userone", avatarUrl: nil, name: "Userone", email: nil, location: nil, bio: nil)
            ))
        }
    }
}
