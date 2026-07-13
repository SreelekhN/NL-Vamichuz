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
        static let dyldInsertLibrariesEnvKey = "DYLD_INSERT_LIBRARIES"
        static let sandboxTestPathPrefix = "/private/jailbreak_test"
        static let forkSymbolName = "fork"
        static let systemFrameworkPathPrefixes = ["/System/Library/", "/usr/lib/"]
        static let urlSessionDataTaskSelectorName = "dataTaskWithRequest:completionHandler:"
        static let secTrustEvaluateSymbolName = "SecTrustEvaluate"
    }
}
