import Foundation

protocol UserProfileService {
    func fetchProfile(login: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
}

final class DefaultUserProfileService: UserProfileService {

    // MARK: - Properties

    var dataTask: URLSessionDataTask?

    // MARK: - UserProfileService

    func fetchProfile(login: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: Constants.endpoint)?.appendingPathComponent(login) else {
            completion(Result.failure(UserServiceError.incorrectRequest))
            return
        }

        dataTask?.cancel()

        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }

            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(Result.failure(UserServiceError.server))
                }
                return
            }

            if let data = data {
                do {
                    let userDtoResult = try JSONDecoder().decode(UserProfileDTO.self, from: data)

                    DispatchQueue.main.async {
                        completion(Result.success(userDtoResult.userProfile))
                    }

                    return
                } catch {
                    DispatchQueue.main.async {
                        completion(Result.failure(UserServiceError.parsing))
                    }
                    return
                }
            }

            DispatchQueue.main.async {
                completion(Result.failure(UserServiceError.unknown))
            }
            return
        }
        dataTask?.resume()
    }
}

// MARK: - Nested Types

extension DefaultUserProfileService {
    enum Constants {
        static let endpoint = "https://api.github.com/users"
    }
}

// MARK: - DTO Mapping

extension UserProfileDTO {
    var userProfile: UserProfile {
        UserProfile(
            id: id,
            login: login,
            avatarUrl: avatarUrl,
            name: name,
            email: email,
            location: location,
            bio: bio
        )
    }
}
