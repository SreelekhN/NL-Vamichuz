//
//  NLConfig.swift
//  Arizone
//
//  Created by sreelekh N on 08/01/24.
//

import Foundation
public final class NLConfig {
    
    public static let shared = NLConfig()
    private init() {}
    
    public var baseUrl = ""
    public var headers: [String: String] = [:]
    public var multiPartFormHeaders: [String: String] = [:]
    public var regularTimeOut = 1.0
    public var uploadTimeout = 30.0
    public var cacheTimeout = 15.0
    public var sessionConfiguration: URLSessionConfiguration?
    public weak var tokenRefreshProvider: NLTokenRefreshProvider?
    public weak var sessionDelegate: URLSessionDelegate? = nil {
        didSet {
            self._session = nil
        }
    }
    private let sessionLock = NSLock()
    private var _session: URLSession?
    public var session: URLSession {
        self.sessionLock.lock()
        defer { self.sessionLock.unlock() }
        if let s = self._session { return s }
        let config = self.sessionConfiguration ?? URLSessionConfiguration.default
        let newSession = URLSession(configuration: config, delegate: self.sessionDelegate, delegateQueue: nil)
        self._session = newSession
        return newSession
    }
}
