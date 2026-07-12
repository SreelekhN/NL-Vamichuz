//
//  TamperDetector.swift
//  NL
//

import Foundation

struct TamperDetector {

    func isTampered(
        scanner: ([String]) -> [String] = DyldImageScanner.suspiciousImageNames,
        denyList: [String] = DyldImageScanner.defaultDenyList,
        hookChecks: [() -> Bool] = Self.defaultHookChecks
    ) -> Bool {
        !scanner(denyList).isEmpty || Self.hasEmbeddedMobileProvision || hookChecks.contains { $0() }
    }

    static let defaultHookChecks: [() -> Bool] = [
        HookDetector.isURLSessionDataTaskHooked,
        HookDetector.isSecTrustEvaluateHooked
    ]

    static var hasEmbeddedMobileProvision: Bool {
        Bundle.main.path(
            forResource: Constants.Security.mobileProvisionResourceName,
            ofType: Constants.Security.mobileProvisionResourceType
        ) != nil
    }
}
