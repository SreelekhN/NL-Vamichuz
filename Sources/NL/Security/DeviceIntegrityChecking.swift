//
//  DeviceIntegrityChecking.swift
//  NL
//

import Foundation

public protocol NLDeviceIntegrityProvider: AnyObject {
    func isDeviceCompromised() async -> Bool
}
