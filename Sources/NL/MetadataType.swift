//
//  MetadataType.swift
//  FuturePlus
//
//  Created by sreelekh N on 01/10/23.
//

import Foundation
enum MetadataType: Decodable {
    
    case stringValue(String)
    case intValue(Int)
    case doubleValue(Double)
    case boolValue(Bool)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .stringValue(value)
            return
        }
        if let value = try? container.decode(Bool.self) {
            self = .boolValue(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self = .doubleValue(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self = .intValue(value)
            return
        }
        throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueWrapper"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .stringValue(value):
            try container.encode(value)
        case let .boolValue(value):
            try container.encode(value)
        case let .intValue(value):
            try container.encode(value)
        case let .doubleValue(value):
            try container.encode(value)
        }
    }
    
    var rawValue: String {
        var result: String
        switch self {
        case let .stringValue(value):
            result = value
        case let .boolValue(value):
            result = String(value)
        case let .intValue(value):
            result = String(value)
        case let .doubleValue(value):
            result = String(Int(value))
        }
        return result
    }
    
    var intValue: Int? {
        var result: Int?
        switch self {
        case let .stringValue(value):
            result = Int(value)
        case let .intValue(value):
            result = value
        case let .boolValue(value):
            result = value ? 1 : 0
        case let .doubleValue(value):
            result = Int(value)
        }
        return result
    }
    
    var boolValue: Bool? {
        var result: Bool?
        switch self {
        case let .stringValue(value):
            result = Bool(value)
        case let .boolValue(value):
            result = value
        case let .intValue(value):
            result = Bool(truncating: value as NSNumber)
        case let .doubleValue(value):
            result = Bool(truncating: value as NSNumber)
        }
        return result
    }
}

enum MetadataArrayOrDictionary<type: Decodable>: Decodable {
    case dictionary(type)
    case array([type])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(type.self) {
            self = .dictionary(value)
            return
        }
        
        if let value = try? container.decode([type].self) {
            self = .array(value)
            return
        }
        throw DecodingError.typeMismatch(MetadataArrayOrDictionary<type>.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueWrapper"))
    }
    
    var dictionary: type? {
        switch self {
        case let .dictionary(value):
            return value
        default:
            return nil
        }
    }
    
    var array: [type]? {
        switch self {
        case let .array(value):
            return value
        default:
            return nil
        }
    }
}
