//
//  LocalAPICommunicator.swift
//  Quoteau
//
//  Created by Wiktor Górka on 24/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation
import RealmSwift

class LocalAPICommunicator {

    static let shared = LocalAPICommunicator()

    let realm = try? Realm()

    func saveQuote(quote: Quote) {
        do {
            try realm?.write {
                realm?.add(quote)
            }
        } catch {
            print("Could not save quote localy")
        }
    }

    func readAllQuotes() -> Results<Quote>? {
        return realm?.objects(Quote.self)
    }
}
