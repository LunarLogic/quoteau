//
//  Common.swift
//  Quoteau
//
//  Created by Wiktor Górka on 28/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation
import FirebaseAuth

enum Common {

    static let defaults = UserDefaults.standard
    static var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    static var userUid: String? {
        return UserDefaults.standard.string(forKey: "userUid")
    }

    static var currentUser: User? {
        Auth.auth().currentUser
    }

    static var currentUserName: String {
        Auth.auth().currentUser?.email ?? ""
    }
}
