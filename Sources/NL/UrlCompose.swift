//
//  Urls.swift
//  Ramz
//
//  Created by sreelekh N on 05/12/21.
//

import Foundation
public protocol HttpsRequestComposeProtocol {
    var url: String { get }
    var trunkUrl: String { get }
    var method: NetworkMethod { get }
    var params: Encodable? { get }
    var header: SessionHeaders { get }
    var data: Data? { get }
    var cacheTimeout: CGFloat { get }
    var shouldCache: Bool { get }
    var forceRefresh: Bool { get }
    var printContent: Bool { get }
}

public struct QuerySendable: Encodable {
    let query: String?
    
    public init(query: String?) {
        self.query = query
    }
}

public extension HttpsRequestComposeProtocol {
    var url: String {
        return NLConfig.shared.baseUrl
    }
    
    var trunkUrl: String {
        return ""
    }
    
    var header: SessionHeaders {
        return [:]
    }
    
    var data: Data? {
        return nil
    }
    
    var params: Encodable? {
        return nil
    }
    
    var cacheTimeout: CGFloat {
        return NLConfig.shared.cacheTimeout
    }
    
    var shouldCache: Bool {
        return false
    }
    
    var forceRefresh: Bool {
        return false
    }
    
    var printContent: Bool {
        return true
    }
}
