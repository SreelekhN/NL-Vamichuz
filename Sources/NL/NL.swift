//
//  NL.swift
//  SocialMob
//
//  Created by sreelekh N on 21/11/21.
//

import Foundation
struct DefaultEncodable: Encodable {}

public protocol HTTPClient {
    var progress: UploadProgressBinder? { get }
    func serverRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
    func amazonUploadFileRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
}

public extension HTTPClient {
    
    var progress: UploadProgressBinder? { 
        nil
    }
    
    var client: UrlSessionLayerProtocol {
        return UrlSessionLayer(session: SessionCall(binder: self.progress))
    }
    
    func serverRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        return await self.client.sendRequest(compose: compose, decoder: decoder)
    }
    
    func amazonUploadFileRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        return await self.client.amazonFileUploadRequest(compose: compose, decoder: decoder)
    }
}
