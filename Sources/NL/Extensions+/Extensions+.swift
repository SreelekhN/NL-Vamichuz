//
//  Extensions+.swift
//
//
//  Created by sreelekh N on 08/01/24.
//

import Foundation
extension String {
    var toUrl: URL {
        let query = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let fileUrl = URL(string: query)
        return fileUrl ?? URL(string: "")!
    }
}
