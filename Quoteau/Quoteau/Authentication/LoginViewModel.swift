//
//  LoginViewModel.swift
//  Quoteau
//
//  Created by Wiktor Górka on 03/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa

class LoginViewModel {

    let email: BehaviorRelay<String> = BehaviorRelay(value: "")
    let password: BehaviorRelay<String> = BehaviorRelay(value: "")
    let isLoggingIn: PublishSubject<Bool> = PublishSubject()
    let userLogged: PublishSubject<Void> = PublishSubject()

    func performLogin() {
        RemoteAPICommunicator.shared.performLogin(email: email.value, password: password.value) { (result) in
            switch result {
            case .success(let uid):
                UserDefaults.standard.set(uid, forKey: "userUid")
                self.sendQuotesToFirebase()
            case .failure(let error):
                print(error)
                self.isLoggingIn.onNext(false)
            }
        }
    }

    fileprivate func sendQuotesToFirebase() {
        var quotes = [Quote]()
        LocalAPICommunicator.shared.readAllQuotes()?.forEach({ (quote) in
            quotes.append(quote)
        })
        if quotes.isEmpty {
            userLogged.onCompleted()
            return
        }
        RemoteAPICommunicator.shared.saveQuotesInFirestre(quotes: quotes) { (result) in
            switch result {
            case .success:
                self.userLogged.onCompleted()
            case .failure(let err):
                print(err)
            }
        }
    }

    var logginButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(passwordValid, emailValid) { $0 && $1 }
    }

    private var passwordValid: Observable<Bool> {
        return password.asObservable().map { !$0.isEmpty }
    }

    private var emailValid: Observable<Bool> {
        return email.asObservable().map { !$0.isEmpty }
    }
}
