//
//  JailbreakDetector.swift
//  NL
//
//  Created by Sreelekh N on 12/07/26.
//

import Foundation
import Darwin

struct JailbreakDetector {

    // Obfuscated so the raw paths don't sit in the binary as plain ASCII (see ObfuscatedString).
    static let obfuscatedSuspiciousPaths: [[UInt8]] = [
        [117, 27, 42, 42, 54, 51, 57, 59, 46, 51, 53, 52, 41, 117, 25, 35, 62, 51, 59, 116, 59, 42, 42],
        [117, 27, 42, 42, 54, 51, 57, 59, 46, 51, 53, 52, 41, 117, 9, 51, 54, 63, 53, 116, 59, 42, 42],
        [117, 27, 42, 42, 54, 51, 57, 59, 46, 51, 53, 52, 41, 117, 0, 63, 56, 40, 59, 116, 59, 42, 42],
        [117, 22, 51, 56, 40, 59, 40, 35, 117, 23, 53, 56, 51, 54, 63, 9, 47, 56, 41, 46, 40, 59, 46, 63, 117, 23, 53, 56, 51, 54, 63, 9, 47, 56, 41, 46, 40, 59, 46, 63, 116, 62, 35, 54, 51, 56],
        [117, 56, 51, 52, 117, 56, 59, 41, 50],
        [117, 47, 41, 40, 117, 41, 56, 51, 52, 117, 41, 41, 50, 62],
        [117, 63, 46, 57, 117, 59, 42, 46],
        [117, 42, 40, 51, 44, 59, 46, 63, 117, 44, 59, 40, 117, 54, 51, 56, 117, 59, 42, 46],
        [117, 44, 59, 40, 117, 54, 51, 56, 117, 57, 35, 62, 51, 59],
        [117, 47, 41, 40, 117, 54, 51, 56, 63, 34, 63, 57, 117, 57, 35, 62, 51, 59]
    ]

    static var suspiciousPaths: [String] {
        Self.obfuscatedSuspiciousPaths.map(ObfuscatedString.decode)
    }

    static let defaultSignals: [(name: String, check: () -> Bool)] = [
        ("suspiciousPaths", Self.suspiciousPathsExist),
        ("sandboxWrite", Self.canWriteOutsideSandbox),
        ("dyldInsertLibraries", Self.hasDyldInsertLibraries)
    ]

    /// Not included in `defaultSignals`: calling raw `fork()` in a live multithreaded process
    /// carries a small inherent stability risk (contention on malloc/ObjC-runtime/dyld atfork
    /// locks) regardless of how it's guarded. Opt in explicitly if that tradeoff is acceptable:
    /// `JailbreakDetector().isJailbroken(signals: JailbreakDetector.defaultSignals + [("forkSucceeds", JailbreakDetector.forkSucceeds)])`
    static let forkSignal: (name: String, check: () -> Bool) = ("forkSucceeds", Self.forkSucceeds)

    static func suspiciousPathsExist() -> Bool {
        suspiciousPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    static func canWriteOutsideSandbox() -> Bool {
        let path = "\(Constants.Security.sandboxTestPathPrefix)_\(UUID().uuidString).txt"
        do {
            try "jailbreak_test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    static func forkSucceeds() -> Bool {
        // `fork()` is marked unavailable by the Swift overlay (Apple pushes threads/posix_spawn
        // instead), but a sandboxed iOS app should never be able to fork regardless of API path —
        // resolve the raw symbol via dlsym to actually exercise that sandbox restriction.
        typealias ForkFn = @convention(c) () -> pid_t
        guard let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), Constants.Security.forkSymbolName) else {
            return false
        }
        let forkFn = unsafeBitCast(symbol, to: ForkFn.self)
        let pid = forkFn()
        if pid >= 0 {
            if pid == 0 {
                // The child inherits any lock another thread held at fork time (malloc, ObjC
                // runtime, dyld) with no thread left to release it. Terminate via SIGKILL rather
                // than _exit(0) so the child can't touch any of those subsystems on its way out.
                kill(getpid(), SIGKILL)
            }
            return true
        }
        return false
    }

    static func hasDyldInsertLibraries() -> Bool {
        guard let value = ProcessInfo.processInfo.environment[Constants.Security.dyldInsertLibrariesEnvKey] else {
            return false
        }
        return !value.isEmpty
    }

    func isJailbroken(signals: [(name: String, check: () -> Bool)] = Self.defaultSignals) -> Bool {
        signals.contains { $0.check() }
    }
}
