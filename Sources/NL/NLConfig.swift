//
//  NLConfig.swift
//  Arizone
//
//  Created by sreelekh N on 08/01/24.
//

import Foundation

// Configured once at app launch (before any network call runs), then only read from
// arbitrary contexts afterward — the compiler can't see that ordering guarantee, so this
// opts out of automatic Sendable checking rather than forcing every NLConfig access
// call site onto @MainActor.
public final class NLConfig: @unchecked Sendable {

    public static let shared = NLConfig()
    private init() {}
    
    public var baseUrl = ""
    public var headers: [String: String] = [:]
    public var multiPartFormHeaders: [String: String] = [:]
    
    // MARK: All timeout is in seconds
    public var regularTimeOut = 60.0
    public var cacheTimeout = 900.0
    public var connectivityGraceTimeout = 7.0
    
    public var sessionConfiguration: URLSessionConfiguration?
    public weak var tokenRefreshProvider: NLTokenRefreshProvider?
    public var securityCheckEnabled = true
    public var debuggerCheckEnabled = false
    public weak var deviceIntegrityProvider: NLDeviceIntegrityProvider?
    public weak var requestPerformanceObserver: NLRequestPerformanceObserver?
    public weak var sessionDelegate: URLSessionDelegate? = nil {
        didSet {
            self.sessionLock.lock()
            self._session = nil
            self.sessionLock.unlock()
        }
    }
    private let sessionLock = NSLock()
    private var _session: URLSession?
    public var session: URLSession {
        self.sessionLock.lock()
        defer { self.sessionLock.unlock() }
        if let s = self._session { return s }
        let config = self.sessionConfiguration ?? URLSessionConfiguration.default
        config.waitsForConnectivity = true
        // Overall ceiling on total request duration; otherwise defaults to 7 days.
        config.timeoutIntervalForResource = self.regularTimeOut
        let newSession = URLSession(configuration: config, delegate: self.sessionDelegate, delegateQueue: nil)
        self._session = newSession
        return newSession
    }
}
