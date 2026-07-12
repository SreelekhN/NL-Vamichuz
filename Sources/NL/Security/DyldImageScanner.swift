//
//  DyldImageScanner.swift
//  NL
//

import Foundation
import MachO

enum DyldImageScanner {

    // Obfuscated so hook/injection tool names don't sit in the binary as plain ASCII (see ObfuscatedString).
    static let obfuscatedDenyList: [[UInt8]] = [
        [28, 40, 51, 62, 59, 29, 59, 62, 61, 63, 46], // FridaGadget
        [60, 40, 51, 62, 59], // frida
        [57, 35, 52, 48, 63, 57, 46], // cynject
        [9, 9, 22, 17, 51, 54, 54, 9, 45, 51, 46, 57, 50], // SSLKillSwitch
        [9, 47, 56, 41, 46, 40, 59, 46, 63, 22, 53, 59, 62, 63, 40], // SubstrateLoader
        [54, 51, 56, 50, 53, 53, 49, 63, 40], // libhooker
        [41, 47, 56, 41, 46, 51, 46, 47, 46, 63] // substitute
    ]

    static var defaultDenyList: [String] {
        Self.obfuscatedDenyList.map(ObfuscatedString.decode)
    }

    static func loadedImageNames() -> [String] {
        let count = _dyld_image_count()
        var names: [String] = []
        names.reserveCapacity(Int(count))
        for index in 0..<count {
            guard let cName = _dyld_get_image_name(index) else { continue }
            names.append(String(cString: cName))
        }
        return names
    }

    static func suspiciousImageNames(denyList: [String] = Self.defaultDenyList) -> [String] {
        loadedImageNames().filter { path in
            let basename = (path as NSString).lastPathComponent
            return denyList.contains { basename.hasPrefix($0) }
        }
    }
}
