//
//  SessionCall.swift
//  Nejree
//
//  Created by sreelekh N on 07/04/22.
//  Copyright © 2022 developer. All rights reserved.
//

import Foundation

protocol SessionCallProtocol {
    func dataRequest(urlRequest: URLRequest, compose: HttpsRequestComposeProtocol) async -> SessionResponse
    func isUploadTask() -> Bool
}

public protocol UploadProgressBinder: AnyObject {
    func uploadprogressFractionCompleted(progress: Double?)
}

final class SessionCall: NSObject, SessionCallProtocol {

    private var progress: NSKeyValueObservation?
    private var connectivityGraceTask: Task<Void, Never>?
    private var timedOutWaitingForConnectivity = false
    weak var binder: UploadProgressBinder?

    init(binder: UploadProgressBinder? = nil) {
        self.binder = binder
    }
    
    func dataRequest(urlRequest: URLRequest, compose: HttpsRequestComposeProtocol) async -> SessionResponse {
        if compose.forceRefresh {
            return await self.directApiCall(urlRequest: urlRequest, compose: compose)
        } else if compose.shouldCache {
            if self.shouldReloadData(for: urlRequest, compose: compose) {
                return await self.directApiCall(urlRequest: urlRequest, compose: compose)
            } else {
                guard let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) else {
                    return await self.directApiCall(urlRequest: urlRequest, compose: compose)
                }
                let returns = (cachedResponse.data, cachedResponse.response)
                return (returns, nil)
            }
        } else {
            return await self.directApiCall(urlRequest: urlRequest, compose: compose)
        }
    }
    
    private func directApiCall(urlRequest: URLRequest, compose: HttpsRequestComposeProtocol) async -> SessionResponse {
        URLCache.shared.removeCachedResponse(for: urlRequest)
        self.timedOutWaitingForConnectivity = false
        do {
            let data = try await NLConfig.shared.session.data(for: urlRequest, delegate: self)
            if compose.shouldCache {
                if let response = data.1 as? HTTPURLResponse {
                    let cachedResponse = CachedURLResponse(
                        response: response,
                        data: data.0,
                        userInfo: nil,
                        storagePolicy: .allowedInMemoryOnly
                    )
                    URLCache.shared.storeCachedResponse(cachedResponse, for: urlRequest)
                }
            }
            return (data, nil)
        } catch {
            if compose.printContent {
                print(error.localizedDescription)
            }
            if self.timedOutWaitingForConnectivity {
                return (nil, URLError(.notConnectedToInternet))
            }
            return (nil, error)
        }
    }
    
    func isUploadTask() -> Bool {
        return self.binder != nil
    }
    
    private func shouldReloadData(for request: URLRequest, compose: HttpsRequestComposeProtocol) -> Bool {
        let timeout: TimeInterval = compose.cacheTimeout
        guard let cachedResponse = URLCache.shared.cachedResponse(for: request),
              let httpResponse = cachedResponse.response as? HTTPURLResponse,
              let dateHeader = httpResponse.allHeaderFields["Date"] as? String,
              let cachedDate = self.parseHttpDate(dateHeader) else {
            return true
        }
        let elapsedTime = Date().timeIntervalSince(cachedDate)
        return elapsedTime > timeout
    }
    
    private static let httpDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private func parseHttpDate(_ dateString: String) -> Date? {
        return Self.httpDateFormatter.date(from: dateString)
    }
    

}

extension SessionCall: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        self.progress = task.progress.observe(\.fractionCompleted) { [weak self] progress, value in
            self?.binder?.uploadprogressFractionCompleted(progress: progress.fractionCompleted)
        }
    }

    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        self.connectivityGraceTask = Task { [weak self] in
            let graceTimeout = NLConfig.shared.connectivityGraceTimeout
            try? await Task.sleep(nanoseconds: UInt64(graceTimeout * 1_000_000_000))
            guard !Task.isCancelled else { return }
            guard task.countOfBytesSent == 0, task.countOfBytesReceived == 0 else { return }
            self?.timedOutWaitingForConnectivity = true
            task.cancel()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.connectivityGraceTask?.cancel()
    }
}

typealias SessionResponse = (UrlSessionResponse, Error?)
typealias UrlSessionResponse = (Data, URLResponse)?




