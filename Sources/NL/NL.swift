//
//  NL.swift
//  SocialMob
//
//  Created by sreelekh N on 21/11/21.
//

import Foundation
struct DefaultEncodable: Encodable {}

protocol HTTPClient {
    func serverRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
    func amazonUploadFileRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
}

extension HTTPClient {
    
    var client: UrlSessionLayerprotocol {
        return UrlSessionLayer()
    }
    
    func serverRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        return await client.sendRequest(compose: compose, decoder: decoder)
    }
    
    func amazonUploadFileRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        return await client.amazonFileUploadRequest(compose: compose, decoder: decoder)
    }
}
