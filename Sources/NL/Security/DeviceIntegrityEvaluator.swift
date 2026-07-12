//
//  DeviceIntegrityEvaluator.swift
//  NL
//

import Foundation

enum DeviceIntegrityEvaluator {

    private static var cachedResult: Bool?
    static var overrideForTesting: Bool?

    static func evaluate() -> Bool {
        if let override = Self.overrideForTesting {
            return override
        }
        if let cached = Self.cachedResult {
            return cached
        }
        var result = JailbreakDetector().isJailbroken() || TamperDetector().isTampered()
        if NLConfig.shared.debuggerCheckEnabled {
            result = result || DebuggerDetector.isDebuggerAttached()
        }
        Self.cachedResult = result
        return result
    }

    static func evaluateAsync() async -> Bool {
        let builtIn = Self.evaluate()
        guard let provider = NLConfig.shared.deviceIntegrityProvider else {
            return builtIn
        }
        return await provider.isDeviceCompromised() || builtIn
    }
}
