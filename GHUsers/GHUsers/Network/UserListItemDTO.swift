import Foundation

struct UserListItemDTO: Decodable {

    let login: String
    let id: Int
    let avatarUrl: URL?

    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
    }
}
