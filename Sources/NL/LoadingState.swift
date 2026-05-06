//
//  LoadingState.swift
//  FuturePlus
//
//  Created by sreelekh N on 05/10/23.
//

import Foundation
public enum LoadingState: Equatable, Hashable {
    case initialState
    case pagination
    case finished
    case noInternet
    case serverError(String)
    case emptyPage
    case searchNotFound
    case privateProfile
    case refresh
    case apartLoading
    case errorStates(ErrorStates)
}

public enum ErrorStates: Equatable, Hashable {
    case failure(String?)
    case sessionFail(String?)
    case emptyPage(EmptyStateContent)
}

public struct EmptyStateContent: Equatable, Hashable {
    public let icon: String?
    public let title: String?
    public let subtitle: String?
    public let btnTitle: String?

    public init(icon: String? = nil, title: String? = nil, subtitle: String? = nil, btnTitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.btnTitle = btnTitle
    }
}
