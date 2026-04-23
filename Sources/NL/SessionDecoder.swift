//
//  SessionDecoder.swift
//  Nejree
//
//  Created by sreelekh N on 19/04/22.
//  Copyright © 2022 developer. All rights reserved.
//

public enum FinalResponse<success: Decodable>  {
    case success(success)
    case failure(String, success?)
    case sessionFail(String)
    case cancelled
}

import Foundation
protocol SessionDecoderDelegate {
    func decodeData<T: Decodable>(response: SessionResponse, compose: HttpsRequestComposeProtocol, decoder: T.Type) -> FinalResponse<T>
}

struct SessionDecoder: SessionDecoderDelegate {
    
    func decodeData<T: Decodable>(response: SessionResponse, compose: HttpsRequestComposeProtocol, decoder: T.Type) -> FinalResponse<T> {
        let error = response.1
        guard let data = response.0?.0,
              let urlResponse = response.0?.1 as? HTTPURLResponse else {
            guard let errors = error as? URLError else {
                return .sessionFail(ErrorMessage.errorMappingFailed.rawValue)
            }
            if errors.code == .cancelled {
                return .cancelled
            }
            return .sessionFail(errors.localizedDescription)
        }
        
        if compose.printContent {
            print(data.prettyPrintedJsonString())
        }
        
        let result = self.handleNetworkResponse(response: urlResponse)
        switch result {
        case .success:
            let decoded = self.decode(data: data, type: decoder)
            guard let decoded else {
                return .failure(ErrorMessage.unableToDecode.rawValue, nil)
            }
            return .success(decoded)
        case .failure(let error):
            let decoded = self.decode(data: data, type: decoder)
            switch error {
            case .failure(let message):
                return .failure(message, decoded)
            default:
                return .failure(error.localizedDescription, decoded)
            }
        }
    }
    
    private func handleNetworkResponse(response: HTTPURLResponse) -> ResultType<NetworkResponseStatus> {
        switch response.statusCode {
        case 200...299:
            return .success
        case 401, 403, 419, 440, 402:
            let message = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            NotificationCenter.default.post(name: .userSessionExpired, object: nil, userInfo: [
                Constants.status: response.statusCode,
                Constants.message: message
            ]
            )
            return .failure(.failure(message: message))
        default:
            let message = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            return .failure(.failure(message: message))
        }
    }
    
    private func decode<T: Decodable>(data: Data, type: T.Type) -> T? {
        let jsonDecoder = JSONDecoder()
        do {
            let object = try jsonDecoder.decode(type, from: data)
            return object
        } catch {
            print(error)
            return nil
        }
    }
}

enum ResultType<Error> {
    case success
    case failure(Error)
}
