//
//  DebuggerDetector.swift
//  NL
//
//  Created by Sreelekh N on 12/07/26.
//

import Foundation
import Darwin

enum DebuggerDetector {

    static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]

        let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        guard result == 0 else {
            return false
        }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
}
