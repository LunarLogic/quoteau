//
//  RegistrationVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 26/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class RegistrationVC: UIViewController {

    let viewModel = RegistrationViewModel()
    let disposeBag = DisposeBag()
    lazy var stackView = UIStackView(arrangedSubviews: [nameTextField,
                                                        emailTextField,
                                                        passwordTextField,
                                                        registerButton])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupBinding()
        setupLayout()
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Bindings
    fileprivate func setupBinding() {
        viewModel.isUserRegistered
            .subscribe(onNext: { [weak self] isRegistered in
                if isRegistered {
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    print("Unable to register / alert")
                }
            }).disposed(by: disposeBag)

        viewModel.registerButtonEnabled
            .subscribe(onNext: { [weak self] isEnabled in
                self?.registerButton.isEnabled = isEnabled
                if isEnabled {
                    self?.registerButton.setTitleColor(.white, for: .normal)
                    self?.registerButton.backgroundColor = UIColor.init(white: 0.7, alpha: 1)
                } else {
                    self?.registerButton.setTitleColor(.black, for: .normal)
                    self?.registerButton.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
                }
            }).disposed(by: disposeBag)

        bind(textField: nameTextField, to: viewModel.fullName)
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

    // MARK: - Private
    @objc fileprivate func handleRegister() {
        viewModel.register()
    }

    // MARK: - Views
    let nameTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Enter full name"
        return textField
    }()

    let emailTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Enter email"
        textField.keyboardType = .emailAddress
        return textField
    }()

    let passwordTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        return textField
    }()

    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.isEnabled = false
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    // MARK: - Constraints
    fileprivate func setupLayout() {
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().inset(35)
            make.centerY.equalToSuperview()
        }
    }
}
