//
//  SessionDecoder.swift
//  Nejree
//
//  Created by sreelekh N on 19/04/22.
//  Copyright © 2022 developer. All rights reserved.
//

public enum FinalResponse<success: Decodable>  {
    case success(success)
    case failure(NetworkResponseStatus, success?)
    case sessionFail(String)
}

import Foundation
protocol SessionDecoderDelegate {
    func decodeData<T: Decodable>(response: SessionResponce, decoder: T.Type) -> FinalResponse<T>
}

struct SessionDecoder: SessionDecoderDelegate {
    
    func decodeData<T: Decodable>(response: SessionResponce, decoder: T.Type) -> FinalResponse<T> {
        let error = response.1
        guard let data = response.0?.0,
              let urlResponse = response.0?.1 as? HTTPURLResponse else {
            guard let errors = error as? URLError else {
                return .sessionFail("Mapping Failed")
            }
            return .sessionFail(errors.localizedDescription)
        }
        debugPrint(data.prettyPrintedJSONString())
        let result = self.handleNetworkResponse(response: urlResponse)
        switch result {
        case .success:
            let decoded = self.decode(data: data, decoder: decoder)
            guard let decoded else {
                return .failure(NetworkResponseStatus.unableToDecode, nil)
            }
            return .success(decoded)
        case .failure(let error):
            let decoded = self.decode(data: data, decoder: decoder)
            return .failure(error, decoded)
        }
    }
    
    private func handleNetworkResponse(response: HTTPURLResponse) -> ResultType<NetworkResponseStatus> {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponseStatus.authenticationError)
        case 501...599: return .failure(NetworkResponseStatus.badRequest)
        case 600: return .failure(NetworkResponseStatus.outdated)
        default: return .failure(NetworkResponseStatus.failed)
        }
    }
    
    private func decode<T: Decodable>(data: Data, decoder: T.Type) -> T? {
        let decoder = JSONDecoder()
        let parser = T.self
        do {
            let object = try decoder.decode(parser, from: data)
            return object
        } catch {
            debugPrint(error)
            return nil
        }
    }
}

enum ResultType<Error> {
    case success
    case failure(Error)
}

extension Data {
    func prettyPrintedJSONString() -> NSString {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return "nil" }
        return prettyPrintedString
    }
}
