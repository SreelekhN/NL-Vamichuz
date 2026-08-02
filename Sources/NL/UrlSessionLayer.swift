//
//  UrlSessionLayer.swift
//  SocialMob
//
//  Created by sreelekh N on 28/02/22.
//

import Foundation
public typealias SessionHeaders = [String: String]?
public typealias PARAMS = [String: Any]?

public protocol UrlSessionLayerProtocol {
    func sendRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
    func amazonFileUploadRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T>
}

public struct UrlSessionLayer: UrlSessionLayerProtocol {
    
    private let sessionDelegate: SessionCallProtocol
    private let decoderDelegate: SessionDecoderDelegate
    private let requestFormer: UrlRequestFormerProtocol
    
    init(
        session: SessionCallProtocol,
        decode: SessionDecoderDelegate = SessionDecoder()
    ) {
        self.sessionDelegate = session
        self.decoderDelegate = decode
        self.requestFormer = UrlRequestFormer()
    }
    
    public func sendRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        if NLConfig.shared.securityCheckEnabled {
            guard await DeviceIntegrityEvaluator.evaluateAsync() == false else {
                return .failure(ErrorMessage.deviceIntegrityCompromised.rawValue, nil)
            }
        }
        guard let urlRequest = self.requestFormer.getUrlRequest(compose: compose) else {
            return .failure(ErrorMessage.badRequest.rawValue, nil)
        }
        let requestStart = Date()
        let sessionResponse = await self.sessionDelegate.dataRequest(urlRequest: urlRequest, compose: compose)

        // MARK: Refresh token checking block

        // 419 = token expired → refresh once and retry
        if let httpResponse = sessionResponse.0?.1 as? HTTPURLResponse,
           httpResponse.statusCode == 419,
           let provider = NLConfig.shared.tokenRefreshProvider {
            let refreshed = await TokenRefreshHandler.shared.refreshIfNeeded(provider: provider)
            if refreshed {
                // Rebuild request from same compose — computed header/params
                // properties are re-evaluated, picking up fresh tokens.
                guard let retryRequest = self.requestFormer.getUrlRequest(compose: compose) else {
                    return .failure(ErrorMessage.badRequest.rawValue, nil)
                }
                let retryResponse = await self.sessionDelegate.dataRequest(urlRequest: retryRequest, compose: compose)
                self.reportPerformance(urlRequest: retryRequest, response: retryResponse, start: requestStart)
                return self.decoderDelegate.decodeData(response: retryResponse, compose: compose, decoder: decoder)
            }
        }

        self.reportPerformance(urlRequest: urlRequest, response: sessionResponse, start: requestStart)
        return self.decoderDelegate.decodeData(response: sessionResponse, compose: compose, decoder: decoder)
    }

    private func reportPerformance(urlRequest: URLRequest, response: SessionResponse, start: Date) {
        guard let observer = NLConfig.shared.requestPerformanceObserver else { return }
        let duration = Date().timeIntervalSince(start)
        let urlString = urlRequest.url?.absoluteString ?? ""
        observer.requestDidComplete(url: urlString, duration: duration, outcome: Self.outcome(for: response))
    }

    private static func outcome(for response: SessionResponse) -> NLRequestOutcome {
        if let urlError = response.1 as? URLError {
            switch urlError.code {
            case .cancelled: return .cancelled
            case .timedOut: return .timeout
            default: return .failure
            }
        }
        if response.1 != nil { return .failure }
        if let httpResponse = response.0?.1 as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            return .failure
        }
        return .success
    }
    
    public func amazonFileUploadRequest<T: Decodable>(compose: HttpsRequestComposeProtocol, decoder: T.Type) async -> FinalResponse<T> {
        if NLConfig.shared.securityCheckEnabled {
            guard await DeviceIntegrityEvaluator.evaluateAsync() == false else {
                return .failure(ErrorMessage.deviceIntegrityCompromised.rawValue, nil)
            }
        }
        guard let urlRequest = self.requestFormer.getAmazonS3FileRequest(compose: compose) else {
            return .failure(ErrorMessage.badRequest.rawValue, nil)
        }
        let sessionResponse = await self.sessionDelegate.dataRequest(urlRequest: urlRequest, compose: compose)
        guard sessionResponse.0 != nil else {
            return .failure(sessionResponse.1?.localizedDescription ?? "", nil)
        }
        let object = AmazonS3UploadModel(code: 200)
        return .success(object as! T)
    }
}
