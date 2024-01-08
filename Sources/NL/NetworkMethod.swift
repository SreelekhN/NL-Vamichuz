//
//  NetworkMethod.swift
//  FuturePlus
//
//  Created by sreelekh N on 05/10/23.
//

import Foundation
public enum NetworkMethod: String {
    case connect = "CONNECT"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
    case query = "QUERY"
    case trace = "TRACE"
}
