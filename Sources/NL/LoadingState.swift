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
    let icon: String?
    let title: String?
    let subtitle: String?
    let btnTitle: String?
}
