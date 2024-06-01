//
//  SessionCall.swift
//  Nejree
//
//  Created by sreelekh N on 07/04/22.
//  Copyright © 2022 developer. All rights reserved.
//

import Foundation

protocol SessionCallProrocol {
    func dataRequest(urlRequest: URLRequest) async -> SessionResponce
}

protocol UploadProgressBinder: AnyObject {
    func uploadprogressFractionCompleted(progress: Double?)
}

final class SessionCall: NSObject, SessionCallProrocol {
    
    private var progress: NSKeyValueObservation?
    weak var binder: UploadProgressBinder?
    
    init(binder: UploadProgressBinder? = nil) {
        self.binder = binder
    }
    
    func dataRequest(urlRequest: URLRequest) async -> SessionResponce {
        do {
            let data = try await URLSession.shared.data(for: urlRequest, delegate: self)
            return (data, nil)
        } catch {
            print(error.localizedDescription)
            return (nil, error)
        }
    }
}

extension SessionCall: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        self.progress = task.progress.observe(\.fractionCompleted) { progress, value in
            print("progress: ", progress.fractionCompleted)
            self.binder?.uploadprogressFractionCompleted(progress: progress.fractionCompleted)
        }
    }
}

typealias SessionResponce = (UrlSessionResponce, Error?)
typealias UrlSessionResponce = (Data, URLResponse)?




