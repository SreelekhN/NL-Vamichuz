import XCTest
import NL

class Tests: XCTestCase, HTTPClient {
    
    var compose: Composer!
    
    override func setUp() {
        super.setUp()
        NLConfig.shared.baseUrl = "https://dummy.restapiexample.com/api/v1/employees"
        self.compose = Composer()
    }
    
    override func tearDown() {
        self.compose = nil
        super.tearDown()
    }
    
    func test_call() {
        Task {
            let response = await self.getResponse()
            switch response {
            case .success(let success):
                XCTAssertEqual(success.status ?? "", "Success")
            case .failure(let networkResponseStatus):
                XCTFail()
            case .sessionFail(let string):
                XCTFail()
            }
        }
    }
    
    private func getResponse() async -> FinalResponse<SomeDecorder> {
        let compose = Composer()
        return await self.client.sendRequest(compose: compose, decoder: SomeDecorder.self)
    }
}

struct Composer: HttpsRequestComposeProtocol {
    var method: NetworkMethod {
        .get
    }
    
    var params: Encodable?
}

struct SomeDecorder: Decodable {
    let status: String?
    let message: String?
}
