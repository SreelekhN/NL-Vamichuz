//
//  LoadingState.swift
//  FuturePlus
//
//  Created by sreelekh N on 05/10/23.
//

import Foundation
public enum LoadingState: Equatable {
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
}
