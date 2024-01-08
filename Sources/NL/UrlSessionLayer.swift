//
//  UrlSessionLayer.swift
//  SocialMob
//
//  Created by sreelekh N on 28/02/22.
//

import Foundation
public typealias SessionHeaders = [String: String]?
public typealias PARAMS = [String: Any]?

public protocol UrlSessionLayerprotocol {
    func sendRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
    func amazonFileUploadRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
}

public struct UrlSessionLayer: UrlSessionLayerprotocol {
    
    private let sessionDelegate: SessionCallProrocol
    private let decoderDelegate: SessionDecoderDelegate
    private let requestFormer: UrlRequestFormerProtocol
    
    init(
        session: SessionCallProrocol = SessionCall(),
        decode: SessionDecoderDelegate = SessionDecoder(),
        requestFormer: UrlRequestFormerProtocol = UrlRequestFormer()
    ) {
        self.sessionDelegate = session
        self.decoderDelegate = decode
        self.requestFormer = requestFormer
    }
    
    public func sendRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        let urlRequest = self.requestFormer.getUrlRequest(compose: compose)
        let sessionResponse = await self.sessionDelegate.request(urlRequest: urlRequest)
        let respose = self.decoderDelegate.decodeData(response: sessionResponse, decoder: decoder)
        return respose
    }
    
    public func amazonFileUploadRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        let urlRequest = self.requestFormer.getAmazonS3FileRequest(compose: compose)
        let sessionResponse = await self.sessionDelegate.request(urlRequest: urlRequest)
        guard sessionResponse.0 != nil else {
            return .failure(NetworkResponseStatus.authenticationError)
        }
        let object = AmazonS3UploadModel(code: 200)
        return .success(object as! T)
    }
}
