//
//  SaveQuoteCollectionVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 24/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

class SaveQuoteVC: UIViewController {

    let disposeBag = DisposeBag()
    let viewModel = SaveQuoteViewModel()
    var quote: String? {
        didSet {
            guard let quote = quote else { return }
            viewModel.quote.accept(quote)
        }
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupConstraints()
        setupBindings()
    }

    // MARK: - Bindings
    fileprivate func setupBindings() {
        bind(textField: quoteNameTextField, to: viewModel.name)
        bind(textField: authorTextField, to: viewModel.author)
        bind(textField: bookTitleTextField, to: viewModel.bookTitle)
        bind(textField: tagsTextField, to: viewModel.tags)

        viewModel.quote
            .asObservable()
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.submitButtonEnabled
            .subscribe(onNext: { [weak self] bool in
                self?.submitButton.isEnabled = bool
                if bool {
                    self?.submitButton.setTitleColor(.white, for: .normal)
                    self?.submitButton.backgroundColor = UIColor.init(white: 0.7, alpha: 1)
                } else {
                    self?.submitButton.setTitleColor(.black, for: .normal)
                    self?.submitButton.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
                }
            }).disposed(by: disposeBag)
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
    @objc fileprivate func handleSubmit() {
        viewModel.saveQuote()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Views
    lazy var stackView = UIStackView(arrangedSubviews: [quoteNameTextField,
                                                        authorTextField,
                                                        bookTitleTextField,
                                                        tagsTextField,
                                                        tagsCollectionView,
                                                        submitButton])

    let quoteNameTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Quote name"
        return textField
    }()

    let authorTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Author (optional)"
        return textField
    }()

    let bookTitleTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Book title"
        return textField
    }()

    let tagsTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "#Tags #... #..."
        return textField
    }()

    let tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        return collectionView
    }()

    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(.systemGray6, for: .normal)
        button.backgroundColor = .blue
//        button.isEnabled = false
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()

    // MARK: - Constraints
    fileprivate func setupConstraints() {
        stackView.distribution = .fillProportionally
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
