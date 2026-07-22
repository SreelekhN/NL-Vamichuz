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
    
    // MARK: All timeout is in seconds
    public var regularTimeOut = 60.0
    public var uploadTimeout = 120.0
    public var cacheTimeout = 900.0
    
    public var sessionConfiguration: URLSessionConfiguration?
    public weak var tokenRefreshProvider: NLTokenRefreshProvider?
    public var securityCheckEnabled = true
    public var debuggerCheckEnabled = false
    public weak var deviceIntegrityProvider: NLDeviceIntegrityProvider?
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
        // Hard ceiling on total request duration, independent of the per-request idle
        // timeout (regularTimeOut/uploadTimeout) and of SessionCall's connectivity-grace
        // check — without this a slow drip of bytes that keeps resetting the idle timer
        // could otherwise hang for URLSession's own default of 7 days.
        config.timeoutIntervalForResource = max(self.regularTimeOut, self.uploadTimeout) + 60
        let newSession = URLSession(configuration: config, delegate: self.sessionDelegate, delegateQueue: nil)
        self._session = newSession
        return newSession
    }
}
