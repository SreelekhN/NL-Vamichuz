//
//  AmazonS3UploadModel.swift
//  FuturePlus
//
//  Created by sreelekh N on 03/10/23.
//

import Foundation
struct AwsModel: Decodable {
    var status: BackendStatus
    var code: Int
    var payload: AwsData?
    var now: String?
}

struct AwsData: Decodable {
    var success: Bool?
    var url: String?
    var filename: String?
}

struct AmazonS3UploadModel: Decodable {
    var code: Int
}

enum BackendStatus: String, Decodable {
    case ok
    case error
}
