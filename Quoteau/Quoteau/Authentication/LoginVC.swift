//
//  LoginVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 03/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LoginVC: UIViewController {

    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupConstraints()
        setupBindings()
    }

    // MARK: - Private
    @objc fileprivate func handleLogin() {
        viewModel.isLoggingIn.onNext(true)
        viewModel.performLogin()
    }

    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Bindings
    fileprivate func setupBindings() {
        viewModel.userLogged
            .subscribe(onCompleted: { [weak self] in
                self?.presentingViewController?.viewDidLoad()
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)

        viewModel.isLoggingIn
            .subscribe(onNext: { [weak self] bool in
                // Spinner?
                self?.loginButton.isEnabled = !bool
            }).disposed(by: disposeBag)

        viewModel.logginButtonEnabled
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.logginButtonEnabled
            .subscribe(onNext: { [weak self] bool in

                self?.loginButton.isEnabled = bool
                if bool {
                    self?.loginButton.setTitleColor(.white, for: .normal)
                    self?.loginButton.backgroundColor = UIColor.init(white: 0.7, alpha: 1)
                } else {
                    self?.loginButton.setTitleColor(.black, for: .normal)
                    self?.loginButton.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
                }

            }).disposed(by: disposeBag)

        bind(textField: emailTextField, to: viewModel.email)
        bind(textField: passwordTextField, to: viewModel.password)
    }

    fileprivate func bind(textField: UITextField,
                          to behaviorRelay: BehaviorRelay<String>) {
        behaviorRelay
            .asObservable()
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
        textField.rx.text
            .flatMap { text in
                return text.map(Observable.just) ?? Observable.empty()
        }
        .bind(to: behaviorRelay)
        .disposed(by: disposeBag)
    }

    // MARK: - Views
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,
                                                       passwordTextField,
                                                       loginButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    let emailTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        return textField
    }()
    let passwordTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        return textField
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.isEnabled = false
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()

    fileprivate let backToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()

    // MARK: - Constraints
    fileprivate func setupConstraints() {
        view.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(50)
            make.centerY.equalToSuperview()
        }

        view.addSubview(backToRegisterButton)
        backToRegisterButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
