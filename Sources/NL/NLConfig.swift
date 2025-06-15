//
//  NLConfig.swift
//  Arizone
//
//  Created by sreelekh N on 08/01/24.
//

import Foundation
public final class NLConfig {
    
    public static let shared = NLConfig()
    public init() {}
    
    public var baseUrl = ""
    public var headers: [String: String] = [:]
    public var multiPartFormHeaders: [String: String] = [:]
    public var regularTimeOut = 1.0
    public var uploadTimeout = 30.0
    public var cacheTimeout = 15.0
    public var sessionConfiguration: URLSessionConfiguration!
    
    public var sessionDelegate: URLSessionDelegate? = nil
    public var session: URLSession {
        let config = self.sessionConfiguration ?? URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self.sessionDelegate, delegateQueue: nil)
    }
}
