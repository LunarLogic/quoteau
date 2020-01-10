//
//  String.swift
//  Quoteau
//
//  Created by Wiktor Górka on 10/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import Foundation

extension String {
    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string,
                                         with: replacement,
                                         options: NSString.CompareOptions.literal,
                                         range: nil)
    }

    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
}
