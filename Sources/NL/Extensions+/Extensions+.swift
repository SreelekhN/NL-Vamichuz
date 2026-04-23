//
//  Extensions+.swift
//
//
//  Created by sreelekh N on 08/01/24.
//

import Foundation
extension String {
    var toUrl: URL? {
        if self.isEmpty {
            return nil
        } else if self.contains("%2") {
            let fileUrl = URL(string: self)
            return fileUrl
        } else {
            let query = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let fileUrl = URL(string: query)
            return fileUrl
        }
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
