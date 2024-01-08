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
        let auth = [
            "Content-Type": "image/png",
            "X-Shopify-Storefront-Access-Token": "b49cf29354f6c92ad4b02b9fb2b60b03"
        ]
        let combined = auth.merging(compose.header ?? [:]) { (_, new) in new }
        return combined
    }
    
    func getHeaders(compose: HttpsRequestComposeProtocol) -> SessionHeaders {
        let auth = [
            "Content-Type": "application/json",
            "X-Shopify-Storefront-Access-Token": "b49cf29354f6c92ad4b02b9fb2b60b03"
        ]
        let combined = auth.merging(compose.header ?? [:]) { (_, new) in new }
        return combined
    }
}
