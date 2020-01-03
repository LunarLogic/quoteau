//
//  ProfileViewModel.swift
//  Quoteau
//
//  Created by Wiktor Górka on 03/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel {
    let profileName: PublishSubject<String> = PublishSubject()
    let isUserLoggedIn: PublishSubject<Bool> = PublishSubject()

    func checkUserStatus() {
        if Common.isUserLoggedIn {
            isUserLoggedIn.onNext(true)
        } else {
            isUserLoggedIn.onNext(false)
        }
    }

    func logout() {
        RemoteAPICommunicator.shared.performLogout(completion: { [weak self] result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "userUid")
                self?.isUserLoggedIn.onNext(false)
            case .failure(let error):
                print(error)
            }
        })
    }
}
