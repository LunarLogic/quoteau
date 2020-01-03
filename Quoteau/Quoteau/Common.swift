//
//  Common.swift
//  Quoteau
//
//  Created by Wiktor Górka on 28/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation

struct Common {

    private init() {}

    static let defaults = UserDefaults.standard
    static var isUserLoggedIn: Bool {
        if UserDefaults.standard.string(forKey: "userUid") != nil {
            return true
        } else {
            return false
        }
    }
    static var userUid: String? {
        return UserDefaults.standard.string(forKey: "userUid")
    }
}
