//
//  RemoteAPICommunicator.swift
//  Quoteau
//
//  Created by Wiktor Górka on 26/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation
import FirebaseAuth

class RemoteAPICommunicator {

    static let shared = RemoteAPICommunicator()

    private init() { }

    func performRegistration(email: String,
                             password: String,
                             completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(res?.user.uid ?? ""))
            print("succesfuly register user", res?.user.uid ?? "" )
        }
    }

    func performLogout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userUid")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
