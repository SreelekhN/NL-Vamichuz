//
//  Authorization.swift
//  FuturePlus
//
//  Created by sreelekh N on 01/10/23.
//

import Foundation
protocol AuthorizationHeaderProtocol {
    func getHeaders(compose: HttpsRequestComposeProtocol) -> SessionHeaders
    func getMultiPartFormHeaders(compose: HttpsRequestComposeProtocol) -> SessionHeaders
}

struct AuthorizationHeader: AuthorizationHeaderProtocol {
    
    func getMultiPartFormHeaders(compose: HttpsRequestComposeProtocol) -> SessionHeaders {
        let auth = NLConfig.shared.multiPartFormHeaders
        if compose.header == [:] {
            return auth
        } else {
            return compose.header ?? [:]
        }
    }
    
    func getHeaders(compose: HttpsRequestComposeProtocol) -> SessionHeaders {
        let auth = NLConfig.shared.headers
        if compose.header == [:] {
            return auth
        } else {
            return compose.header ?? [:]
        }
    }
}
