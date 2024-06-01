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
