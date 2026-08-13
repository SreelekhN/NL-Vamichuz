//
//  DeviceIntegrityEvaluator.swift
//  NL
//
//  Created by Sreelekh N on 12/07/26.
//

import Foundation

enum DeviceIntegrityEvaluator {

    private static let lock = NSLock()
    // Both guarded by `lock` (or, for `overrideForTesting`, only ever set once before
    // any concurrent access begins in test setup) — safe under manual synchronization
    // that the compiler can't otherwise verify.
    nonisolated(unsafe) private static var cachedResult: Bool?
    nonisolated(unsafe) static var overrideForTesting: Bool?

    static func evaluate() -> Bool {
        if let override = Self.overrideForTesting {
            return override
        }
        Self.lock.lock()
        let staticResult: Bool
        if let cached = Self.cachedResult {
            staticResult = cached
        } else {
            staticResult = JailbreakDetector().isJailbroken() || TamperDetector().isTampered()
            Self.cachedResult = staticResult
        }
        Self.lock.unlock()

        // Debugger attachment can happen at any point after launch, so it's checked fresh
        // every call instead of being folded into the one-time cached result above.
        guard NLConfig.shared.debuggerCheckEnabled else {
            return staticResult
        }
        return staticResult || DebuggerDetector.isDebuggerAttached()
    }

    private static var isWarm: Bool {
        Self.lock.lock()
        defer { Self.lock.unlock() }
        return Self.cachedResult != nil
    }

    static func evaluateAsync() async -> Bool {
        // evaluate() only does blocking work (file I/O, dyld image scan, fork()) on the very
        // first call before the result is cached — only that call needs to hop off the
        // caller's context. Every later call is a cheap cache read and can run inline so
        // steady-state requests don't pay a Task-creation cost on every single API call.
        let builtIn: Bool
        if Self.overrideForTesting != nil || Self.isWarm {
            builtIn = Self.evaluate()
        } else {
            builtIn = await Task.detached(priority: .utility) {
                Self.evaluate()
            }.value
        }
        guard let provider = NLConfig.shared.deviceIntegrityProvider else {
            return builtIn
        }
        return await provider.isDeviceCompromised() || builtIn
    }
}
