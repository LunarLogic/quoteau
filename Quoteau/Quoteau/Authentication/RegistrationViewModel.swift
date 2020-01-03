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
        RemoteAPICommunicator.shared.performRegistration(email: email.value,
                                                         password: password.value) { result in
                                                            switch result {
                                                            case .success(let uid):
                                                                UserDefaults.standard.set(uid, forKey: "userUid")
                                                                self.isUserRegistered.onNext(true)
                                                            case .failure(let error):
                                                                print(error)
                                                                self.isUserRegistered.onNext(false)
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
