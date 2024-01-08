//
//  SessionCall.swift
//  Nejree
//
//  Created by sreelekh N on 07/04/22.
//  Copyright © 2022 developer. All rights reserved.
//

import Foundation

protocol SessionCallProrocol {
    func request(urlRequest: URLRequest) async -> SessionResponce
}

final class SessionCall: SessionCallProrocol {
    
    init() {}
    
    func request(urlRequest: URLRequest) async -> SessionResponce {
        do {
            let data = try await URLSession.shared.data(for: urlRequest)
            return (data, nil)
        } catch {
            print(error.localizedDescription)
            return (nil, error)
        }
    }
}

typealias SessionResponce = (UrlSessionResponce, Error?)
typealias UrlSessionResponce = (Data, URLResponse)?




