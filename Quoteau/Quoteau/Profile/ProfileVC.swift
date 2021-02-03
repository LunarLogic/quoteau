//
//  ProfileVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 26/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class ProfileVC: UIViewController {

    let viewModel = ProfileViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .quoteauViewControllerBackgroundColor
        setupConstraint()
        navigationItem.title = "Hello \(Common.currentUserName)"
        setupBindings()
        viewModel.checkUserStatus()
    }

    // MARK: - Bindings
    fileprivate func setupBindings() {
        viewModel.isUserLoggedIn
            .subscribe(onNext: { [weak self] isLoggedIn in
                self?.signInButton.setTitle(isLoggedIn ? "Logout" : "Sign In", for: .normal)
            }).disposed(by: disposeBag)
    }

    // MARK: - Private
    @objc fileprivate func handleChangeUserStatus() {
        if Common.isUserLoggedIn {
            viewModel.logout()
        } else {
            let registrationVC = RegistrationVC()
            let navRegistrationVC = UINavigationController(rootViewController: registrationVC)
            present(navRegistrationVC, animated: true, completion: nil)
        }
    }

    // MARK: - Views
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
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
