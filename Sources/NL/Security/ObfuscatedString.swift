//
//  ObfuscatedString.swift
//  NL
//
//  Created by Sreelekh N on 12/07/26.
//

import Foundation

// Keeps sensitive detector strings (jailbreak paths, hook/injection tool names) out of the
// binary's plain __cstring section so they don't show up in a `strings` dump / static analysis.
enum ObfuscatedString {

    private static let key: UInt8 = 0x5A

    static func decode(_ bytes: [UInt8]) -> String {
        let decoded = bytes.map { $0 ^ Self.key }
        return String(decoding: decoded, as: UTF8.self)
    }
}
