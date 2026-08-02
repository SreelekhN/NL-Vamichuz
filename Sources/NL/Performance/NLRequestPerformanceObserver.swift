//
//  NLRequestPerformanceObserver.swift
//  NL
//
//  Created by Sreelekh N on 02/08/26.
//

import Foundation

public enum NLRequestOutcome {
    case success
    case failure
    case timeout
    case cancelled
}

public protocol NLRequestPerformanceObserver: AnyObject {
    func requestDidComplete(url: String, duration: TimeInterval, outcome: NLRequestOutcome)
}
