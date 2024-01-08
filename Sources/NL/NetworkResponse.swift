//
//  NetworkResponse.swift
//  SocialMob
//
//  Created by sreelekh N on 06/10/22.
//  Copyright © 2022 Sreelekh_N. All rights reserved.
//

import Foundation
enum NetworkResponseStatus: String, Error {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
    case loginExpired = "Login Expired"
    case badUrl = "A malformed URL prevented a URL request from being initiated."
    case badServerResponse = "The URL Loading System received bad data from the server."
    case unsupportedURL = "A properly formed URL couldn’t be handled by the framework."
    case timedOut = "The request timed out."
    case cannotFindHost = "The host name for a URL could not be resolved."
}
