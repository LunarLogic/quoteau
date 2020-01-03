//
//  ProfileVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 26/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth

class ProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupConstraint()
        navigationItem.title = "User name"
    }

    @objc fileprivate func handleChangeUserStatus() {
        if Common.isUserLoggedIn {
            RemoteAPICommunicator.shared.performLogout()
        } else {
            let navRegistrationVC = UINavigationController(rootViewController: RegistrationVC())
                       present(navRegistrationVC, animated: true, completion: nil)
        }
    }

    // MARK: - Views
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Common.isUserLoggedIn ? "Logout" : "Sign In", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleChangeUserStatus), for: .touchUpInside)
        return button
    }()
    // MARK: - Constraints
    fileprivate func setupConstraint() {
        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp_bottomMargin).inset(12)
            make.height.equalTo(44)
            make.trailing.leading.equalToSuperview().inset(12)
        }
    }
}
