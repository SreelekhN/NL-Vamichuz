//
//  TamperDetector.swift
//  NL
//
//  Created by Sreelekh N on 12/07/26.
//

import Foundation

struct TamperDetector {
    func isTampered(
        scanner: ([String]) -> [String] = DyldImageScanner.suspiciousImageNames,
        denyList: [String] = DyldImageScanner.defaultDenyList,
        hookChecks: [() -> Bool] = Self.defaultHookChecks
    ) -> Bool {
        !scanner(denyList).isEmpty || hookChecks.contains { $0() }
    }

    static let defaultHookChecks: [() -> Bool] = [
        HookDetector.isURLSessionDataTaskHooked,
        HookDetector.isSecTrustEvaluateHooked
    ]
}
