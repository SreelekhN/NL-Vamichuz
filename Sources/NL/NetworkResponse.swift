//
//  NetworkResponse.swift
//  SocialMob
//
//  Created by sreelekh N on 06/10/22.
//  Copyright © 2022 Sreelekh_N. All rights reserved.
//

import Foundation
public enum NetworkResponseStatus: Error {
    case success
    case failure(message: String)
}

public enum ErrorMessage: String, Error {
    case unableToDecode = "We could not decode the response."
    case badRequest = "Response with bad request."
    case errorMappingFailed = "Error mapping failed."
}
