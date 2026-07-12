//
//  Constants.swift
//  NL
//
//  Created by Sreelekh N on 23/04/26.
//

enum Constants {
    static let status = "status"
    static let message = "message"

    enum Security {
        static let mobileProvisionResourceName = "embedded"
        static let mobileProvisionResourceType = "mobileprovision"
        static let dyldInsertLibrariesEnvKey = "DYLD_INSERT_LIBRARIES"
        static let sandboxTestPath = "/private/jailbreak_test.txt"
        static let forkSymbolName = "fork"
        static let systemFrameworkPathPrefixes = ["/System/Library/", "/usr/lib/"]
        static let urlSessionDataTaskSelectorName = "dataTaskWithRequest:completionHandler:"
        static let secTrustEvaluateSymbolName = "SecTrustEvaluate"
    }
}
