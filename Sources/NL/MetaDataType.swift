//
//  MetaDataType.swift
//  FuturePlus
//
//  Created by sreelekh N on 01/10/23.
//

import Foundation

public enum MetaDataType: Codable, Hashable {
    
    case stringValue(String)
    case intValue(Int)
    case doubleValue(Double)
    case floatValue(Float)
    case boolValue(Bool)
    case arrayValue([MetaDataType])
    case dictionaryValue([String: MetaDataType])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self = .stringValue(value)
            return
        }
        if let value = try? container.decode(Bool.self) {
            self = .boolValue(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self = .intValue(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self = .doubleValue(value)
            return
        }
        if let value = try? container.decode(Float.self) {
            self = .floatValue(value)
            return
        }
        if let value = try? container.decode([MetaDataType].self) {
            self = .arrayValue(value)
            return
        }
        if let value = try? container.decode([String: MetaDataType].self) {
            self = .dictionaryValue(value)
            return
        }
        
        throw DecodingError.typeMismatch(
            MetaDataType.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported type for MetadataType"
            )
        )
    }
    
    public func encode(to encoder: Encoder) throws {
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
        case let .floatValue(value):
            try container.encode(value)
        case let .arrayValue(value):
            try container.encode(value)
        case let .dictionaryValue(value):
            try container.encode(value)
        }
    }
    
    var rawValue: String {
        switch self {
        case let .stringValue(value):
            return value
        case let .boolValue(value):
            return String(value)
        case let .intValue(value):
            return String(value)
        case let .doubleValue(value):
            return String(value)
        case let .floatValue(value):
            return String(value)
        case let .arrayValue(value):
            return value.map { $0.rawValue }.joined(separator: ", ")
        case let .dictionaryValue(value):
            return value.map { "\($0.key): \($0.value.rawValue)" }.joined(separator: ", ")
        }
    }
    
    var intValue: Int? {
        switch self {
        case let .stringValue(value):
            return Int(value)
        case let .intValue(value):
            return value
        case let .boolValue(value):
            return value ? 1 : 0
        case let .doubleValue(value):
            return Int(value)
        case let .floatValue(value):
            return Int(value)
        default:
            return nil
        }
    }
    
    var boolValue: Bool? {
        switch self {
        case let .stringValue(value):
            return Bool(value)
        case let .boolValue(value):
            return value
        case let .intValue(value):
            return value != 0
        case let .doubleValue(value):
            return value != 0.0
        case let .floatValue(value):
            return value != 0.0
        default:
            return nil
        }
    }
    
    var arrayValue: [MetaDataType]? {
        if case let .arrayValue(value) = self {
            return value
        }
        return nil
    }
    
    var dictionaryValue: [String: MetaDataType]? {
        if case let .dictionaryValue(value) = self {
            return value
        }
        return nil
    }
}
