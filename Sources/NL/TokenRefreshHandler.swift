//
//  TokenRefreshHandler.swift
//  NL
//
//  Created by Sreelekh N on 07/04/26.
//

import Foundation

public protocol NLTokenRefreshProvider: AnyObject {
    func refreshToken() async -> Bool
}

actor TokenRefreshHandler {

    static let shared = TokenRefreshHandler()

    private var isRefreshing = false
    private var waiters: [CheckedContinuation<Bool, Never>] = []

    func refreshIfNeeded(provider: NLTokenRefreshProvider) async -> Bool {
        if self.isRefreshing {
            return await withCheckedContinuation { continuation in
                self.waiters.append(continuation)
            }
        }
        self.isRefreshing = true
        let success = await provider.refreshToken()

        // Wake every queued caller with the same result.
        for waiter in self.waiters {
            waiter.resume(returning: success)
        }
        self.waiters.removeAll()
        self.isRefreshing = false
        return success
    }
}
