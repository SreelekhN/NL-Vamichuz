//
//  HookDetector.swift
//  NL
//
//  Created by Sreelekh N on 12/07/26.
//

import Foundation
import Darwin
import ObjectiveC

// Detects method swizzling / function hooking on the exact APIs interception tools
// (Frida scripts, SSL Kill Switch, etc.) target to intercept or bypass NL's own traffic.
enum HookDetector {

    static func isImplementationHooked(class aClass: AnyClass, selector: Selector) -> Bool {
        guard let method = class_getInstanceMethod(aClass, selector) else {
            return false
        }
        return Self.isPointerOutsideSystemImage(UnsafeRawPointer(method_getImplementation(method)))
    }

    static func isURLSessionDataTaskHooked() -> Bool {
        Self.isImplementationHooked(
            class: URLSession.self,
            selector: NSSelectorFromString(Constants.Security.urlSessionDataTaskSelectorName)
        )
    }

    static func isSecTrustEvaluateHooked() -> Bool {
        guard let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), Constants.Security.secTrustEvaluateSymbolName) else {
            return false
        }
        return Self.isPointerOutsideSystemImage(symbol)
    }

    static func isPointerOutsideSystemImage(
        _ pointer: UnsafeRawPointer,
        dladdr: (UnsafeRawPointer, UnsafeMutablePointer<Dl_info>) -> Int32 = Darwin.dladdr
    ) -> Bool {
        var info = Dl_info()
        guard dladdr(pointer, &info) != 0, let fnamePointer = info.dli_fname else {
            return true
        }
        let path = String(cString: fnamePointer)
        return !Constants.Security.systemFrameworkPathPrefixes.contains { path.hasPrefix($0) }
    }
}
