//
//  DeviceIntegrityChecking.swift
//  NL
//
//  Created by Sreelekh N on 12/07/26.
//

import Foundation

public protocol NLDeviceIntegrityProvider: AnyObject {
    func isDeviceCompromised() async -> Bool
}
