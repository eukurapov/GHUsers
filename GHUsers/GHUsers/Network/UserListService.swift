import Foundation

protocol UserListService {
    func fetch(page: Int, completion: @escaping (Result<[UserListItem], Error>) -> Void)
}

final class DefaultUserListService: UserListService {

    // MARK: - Properties

    private var pageToUrl: [Int: URL] = [:]
    private var dataTask: URLSessionDataTask?

    // MARK: - Lifecycle

    init() {
        pageToUrl[1] = URL(string: Constants.endpoint)
    }

    // MARK: - UserListService

    func fetch(page: Int, completion: @escaping (Result<[UserListItem], Error>) -> Void) {
        guard let pageUrl = pageToUrl[page] else {
            completion(Result.failure(UserServiceError.incorrectRequest))
            return
        }

        dataTask?.cancel()

        dataTask = URLSession.shared.dataTask(with: pageUrl) { [weak self] data, response, error in
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

            let nextUrl = httpResponse.nextLink.flatMap { URL(string: $0) }

            if let data = data {
                do {
                    let userDtoResult = try JSONDecoder().decode([UserListItemDTO].self, from: data)

                    DispatchQueue.main.async {
                        completion(Result.success(userDtoResult.map(\.userListItem)))
                    }

                    self?.pageToUrl[page + 1] = nextUrl
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

extension DefaultUserListService {
    enum Constants {
        static let endpoint = "https://api.github.com/users"
    }
}

// MARK: - DTO Mapping

extension UserListItemDTO {
    var userListItem: UserListItem {
        UserListItem(
            id: id,
            login: login,
            avatarUrl: avatarUrl
        )
    }
}
