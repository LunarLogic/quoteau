//
//  RemoteAPICommunicator.swift
//  Quoteau
//
//  Created by Wiktor Górka on 26/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class RemoteAPICommunicator {

    static let shared = RemoteAPICommunicator()

    let usersCollection = "users"
    let quotesCollection = "quotes"

    private init() { }

    func performRegistration(
        email: String,
        password: String,
        name: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let uid = res?.user.uid else { return }
            self.saveUserDataInFirestore(email: email, name: name, uid: uid) { (result) in
                switch result {
                case .success:
                    completion(.success(res?.user.uid ?? ""))
                    print("succesfuly saved user in firestore", res?.user.uid ?? "" )
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func performLogout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            completion(.failure(signOutError))
        }
    }

    func performLogin(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(res?.user.uid ?? ""))
            print("succesfuly login user", res?.user.uid ?? "" )
        }
    }

    func saveUserDataInFirestore(
        email: String,
        name: String,
        uid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let data = ["email": email, "name": name]
        Firestore.firestore().collection(usersCollection).document(uid).setData(data) { (err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(()))
        }
    }

    func saveQuotesInFirestore(quotes: [Quote], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Common.userUid else { return }
        quotes.forEach { (quote) in
            do {
                guard let docData = try FirebaseEncoder().encode(quote) as? [String: Any] else { return }
                Firestore.firestore()
                    .collection(usersCollection)
                    .document(uid)
                    .collection(quotesCollection)
                    .document(quote.timestamp)
                    .setData(docData) { (err) in
                        if let err = err {
                            completion(.failure(err))

                        }
                        completion(.success(()))
                    }
            } catch {
                print("Unable to encode data")
            }
        }
    }
}
