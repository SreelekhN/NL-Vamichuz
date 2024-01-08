//
//  UrlRequestFormer.swift
//  SocialMob
//
//  Created by sreelekh N on 23/06/23.
//  Copyright © 2023 Sreelekh_N. All rights reserved.
//

import Foundation
protocol UrlRequestFormerProtocol {
    func getAmazonS3FileRequest(compose: HttpsRequestComposeProtocol) -> URLRequest
    func getUrlRequest(compose: HttpsRequestComposeProtocol) -> URLRequest
}

struct UrlRequestFormer: UrlRequestFormerProtocol {
    
    private let header: AuthorizationHeaderProtocol
    
    init(header: AuthorizationHeaderProtocol = AuthorizationHeader()) {
        self.header = header
    }
    
    func getUrlRequest(compose: HttpsRequestComposeProtocol) -> URLRequest {
        let headers = self.header.getHeaders(compose: compose)
        let url = compose.url.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlConverted = url.toUrl
        var request = URLRequest(url: urlConverted)
        request.httpMethod = compose.method.rawValue
        if let headers {
            request.allHTTPHeaderFields = headers
            debugPrint("sending header = \(headers)")
        }
        debugPrint(url)
        switch compose.method {
        case .post:
            if let encoded = compose.params {
                do {
                    let body = try JSONEncoder().encode(encoded)
                    request.httpBody = body
                } catch {}
                printEncode(decodable: encoded)
            }
        default:
            break
        }
        return request
    }
    
    func getAmazonS3FileRequest(compose: HttpsRequestComposeProtocol) -> URLRequest {
        let headers = self.header.getHeaders(compose: compose)
        let url = compose.url.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlConverted = url.toUrl
        
        var request = URLRequest(url: urlConverted)
        request.httpMethod = compose.method.rawValue
        request.httpBody = compose.data
        request.setValue("image/png", forHTTPHeaderField: "Content-Type")
        if let headers {
            request.allHTTPHeaderFields = headers
            debugPrint("sending header = \(headers)")
        }
        return request
    }
    
    private func printEncode<T: Encodable>(decodable: T) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            guard let data = try? encoder.encode(decodable), let output = String(data: data, encoding: .utf8) else { return }
            debugPrint("sending json = \(output)")
        }
    }
}
