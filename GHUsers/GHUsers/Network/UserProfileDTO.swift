import Foundation

struct UserProfileDTO: Decodable {

    let id: Int
    let login: String
    let avatarUrl: URL?
    let name: String?
    let email: String?
    let location: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case name
        case email
        case location
        case bio
    }
}
