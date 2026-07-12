//
//  JailbreakDetector.swift
//  NL
//

import Foundation
import Darwin

struct JailbreakDetector {

    // Obfuscated so the raw paths don't sit in the binary as plain ASCII (see ObfuscatedString).
    static let obfuscatedSuspiciousPaths: [[UInt8]] = [
        [117, 27, 42, 42, 54, 51, 57, 59, 46, 51, 53, 52, 41, 117, 25, 35, 62, 51, 59, 116, 59, 42, 42], // /Applications/Cydia.app
        [117, 27, 42, 42, 54, 51, 57, 59, 46, 51, 53, 52, 41, 117, 9, 51, 54, 63, 53, 116, 59, 42, 42], // /Applications/Sileo.app
        [117, 27, 42, 42, 54, 51, 57, 59, 46, 51, 53, 52, 41, 117, 0, 63, 56, 40, 59, 116, 59, 42, 42], // /Applications/Zebra.app
        [117, 22, 51, 56, 40, 59, 40, 35, 117, 23, 53, 56, 51, 54, 63, 9, 47, 56, 41, 46, 40, 59, 46, 63, 117, 23, 53, 56, 51, 54, 63, 9, 47, 56, 41, 46, 40, 59, 46, 63, 116, 62, 35, 54, 51, 56], // /Library/MobileSubstrate/MobileSubstrate.dylib
        [117, 56, 51, 52, 117, 56, 59, 41, 50], // /bin/bash
        [117, 47, 41, 40, 117, 41, 56, 51, 52, 117, 41, 41, 50, 62], // /usr/sbin/sshd
        [117, 63, 46, 57, 117, 59, 42, 46], // /etc/apt
        [117, 42, 40, 51, 44, 59, 46, 63, 117, 44, 59, 40, 117, 54, 51, 56, 117, 59, 42, 46], // /private/var/lib/apt
        [117, 44, 59, 40, 117, 54, 51, 56, 117, 57, 35, 62, 51, 59], // /var/lib/cydia
        [117, 47, 41, 40, 117, 54, 51, 56, 63, 34, 63, 57, 117, 57, 35, 62, 51, 59] // /usr/libexec/cydia
    ]

    static var suspiciousPaths: [String] {
        Self.obfuscatedSuspiciousPaths.map(ObfuscatedString.decode)
    }

    static let defaultSignals: [(name: String, check: () -> Bool)] = [
        ("suspiciousPaths", Self.suspiciousPathsExist),
        ("sandboxWrite", Self.canWriteOutsideSandbox),
        ("forkSucceeds", Self.forkSucceeds),
        ("dyldInsertLibraries", Self.hasDyldInsertLibraries)
    ]

    static func suspiciousPathsExist() -> Bool {
        suspiciousPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    static func canWriteOutsideSandbox() -> Bool {
        let path = Constants.Security.sandboxTestPath
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
                _exit(0)
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
