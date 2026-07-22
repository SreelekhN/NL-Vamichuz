//
//  Extensions+.swift
//
//
//  Created by sreelekh N on 08/01/24.
//

import Foundation
extension String {
    var toUrl: URL? {
        guard !self.isEmpty else { return nil }
        if let decoded = self.removingPercentEncoding, decoded != self {
            return URL(string: self)
        }
        let query = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: query)
    }
}

extension Data {
    func prettyPrintedJsonString() -> NSString {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted]
              ),
              let prettyPrintedString = NSString(
                data: data,
                encoding: String.Encoding.utf8.rawValue
              ) else { return "response is null" }
        return prettyPrintedString
    }
}
