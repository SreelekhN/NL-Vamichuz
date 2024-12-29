import XCTest
@testable import NL

final class NLTests: XCTestCase {
    
    
    override func setUpWithError() throws {
        // self.nowDate = Date()
    }
    
    override func tearDownWithError() throws {
//        self.comparor = nil
//        self.nowDate = nil
//        self.oldDate = nil
    }
    
    protocol TestClientProtocol {
        func getLatestConversionRates() async -> FinalResponse<ExchangeDecorder>
    }
    
    struct TestClient: HTTPClient, TestClientProtocol {
        func getLatestConversionRates() async -> FinalResponse<ExchangeDecorder> {
            let compose = ConvertCompose()
            return await self.serverRequest(compose: compose,
                                            decoder: ExchangeDecorder.self)
        }
    }
    
    private let client: TestClientProtocol = TestClient()
    
    func testDummyApiCall() async {
        let response = await self.client.getLatestConversionRates()
        switch response {
        case .success(let success):
            print(success)
        case .failure(let networkResponseStatus, let success):
            print(networkResponseStatus)
            print(success)
        case .sessionFail(let string):
            print(string)
        }
    }
}

import Foundation
struct ExchangeDecorder: Decodable, Equatable {
    let disclaimer: String?
    let license: String?
    let timestamp: Int?
    let base: String?
    var rates: [Rates]?
    
    //Fail
    let status: Int?
    let message: String?
    let description: String?
    let error: Bool?
   
    init(disclaimer: String?,
         license: String?,
         timestamp: Int?,
         base: String?,
         rates: [Rates]?
    ) {
        self.disclaimer = disclaimer
        self.license = license
        self.timestamp = timestamp
        self.base = base
        self.rates = rates
        self.status = nil
        self.description = nil
        self.message = nil
        self.error = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case disclaimer, license, timestamp, base
        case rates
        case status, message, description, error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disclaimer = try? container.decode(String.self, forKey: .disclaimer)
        self.license = try? container.decode(String.self, forKey: .license)
        self.timestamp = Int(NSDate().timeIntervalSince1970)
        self.base = try? container.decode(String.self, forKey: .base)
        let rates = try? container.decode([String: Double].self, forKey: .rates)
        let map = rates?.compactMap { now in
            return Rates(key: now.key, rate: now.value)
        }
        self.rates = map
        
        self.status = try? container.decode(Int.self, forKey: .status)
        self.message = try? container.decode(String.self, forKey: .message)
        self.description = try? container.decode(String.self, forKey: .description)
        self.error = try? container.decode(Bool.self, forKey: .error)
    }
}

struct Rates: Decodable, Equatable, Hashable {
    
    static func == (lhs: Rates, rhs: Rates) -> Bool {
        return lhs.key == rhs.key
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    let key: String?
    let rate: Double?
}

struct ConvertCompose: HttpsRequestComposeProtocol {
    
    var trunkUrl: String {
        return "latest.json?app_id=\(AppDetails.appId)"
    }
    
    var method: NetworkMethod {
        return .get
    }
    
    var params: Encodable?
}

enum AppDetails {
    static let appName = "PayPay"
    static let appId = "acf7e03c26b443a9bb263a6fc2f98f90"
}
//
//private var client: ConverterClientProtocol!
//
//override func setUpWithError() throws {
//    self.client = ConverterClient()
//}
//
//override func tearDownWithError() throws {
//    self.client = nil
//}
//
//func testGetLatestConversionRates() async throws {
//    
//    // Use expectation for closures
//    
//    let response = await self.client.getLatestConversionRates()
//    switch response {
//    case .success(let success):
//        XCTAssertNotNil(success)
//        XCTAssertNotNil(success.timestamp)
//        XCTAssertNotNil(success.rates)
//        XCTAssertNotNil(success.base)
//        XCTAssertEqual(success.base, "USD")
//        XCTAssertGreaterThanOrEqual(success.rates?.count ?? 0, 1)
//    case .failure(let alert, let decoded):
//        XCTAssert(false)
//    case .sessionFail(let string):
//        XCTAssert(false)
//    }
//}
