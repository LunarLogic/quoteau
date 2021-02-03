//
//  RegistrationViewModel.swift
//  Quoteau
//
//  Created by Wiktor Górka on 26/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RegistrationViewModel {

    let fullName: BehaviorRelay<String> = BehaviorRelay(value: "")
    let email: BehaviorRelay<String> = BehaviorRelay(value: "")
    let password: BehaviorRelay<String> = BehaviorRelay(value: "")
    let isUserRegistered: PublishSubject<Bool> = PublishSubject()

    func register() {
        RemoteAPICommunicator.shared.performRegistration(
            email: email.value,
            password: password.value,
            name: fullName.value
        ) { result in
            switch result {
            case .success(let uid):
                UserDefaults.standard.set(uid, forKey: "userUid")
                self.sendQuotesToFirebase()
            case .failure(let error):
                print(error)
                self.isUserRegistered.onNext(false)
            }
        }
    }

    fileprivate func sendQuotesToFirebase() {
        var quotes = [Quote]()
        LocalAPICommunicator.shared.readAllQuotes()?.forEach({ (quote) in
            quotes.append(quote)
        })
        if quotes.isEmpty {
            self.isUserRegistered.onNext(true)
            return
        }
        RemoteAPICommunicator.shared.saveQuotesInFirestore(quotes: quotes) { (result) in
            switch result {
            case .success:
                self.isUserRegistered.onNext(true)
            case .failure(let err):
                print(err)
            }
        }
    }

    var registerButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(nameValid, passwordValid, emailValid) { $0 && $1 && $2 }
    }

    private var nameValid: Observable<Bool> {
        return fullName.asObservable().map { !$0.isEmpty }
    }

    private var passwordValid: Observable<Bool> {
        return password.asObservable().map { !$0.isEmpty }
    }

    private var emailValid: Observable<Bool> {
        return email.asObservable().map { !$0.isEmpty }
    }
}
