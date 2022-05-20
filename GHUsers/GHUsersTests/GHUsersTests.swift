import XCTest
@testable import GHUsers

class GHUsersTests: XCTestCase {

    func testFetchUserListUseCase() throws {
        let useCase = DefaultFetchUserListUseCase(userListService: DummyUserListService())
        let params = FetchUserListUseCaseParams(pageNumber: 1)
        useCase.fetch(params: params) { result in
            var resultItems: [UserListItem] = []

            switch result {
            case let .success(items):
                resultItems = items
            case let .failure(error):
                XCTFail("Unexpected failure with error \(error)")
            }

            XCTAssertEqual(resultItems.count, 3)
            XCTAssertEqual(resultItems.first?.login, "userone")
        }
    }
}
