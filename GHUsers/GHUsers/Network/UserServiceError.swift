enum UserServiceError: Error {
    case incorrectRequest
    case server
    case parsing
    case unknown
}
