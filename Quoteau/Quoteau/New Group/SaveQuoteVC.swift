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

class SaveQuoteVC: UIViewController {

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupConstraints()
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
        textField.placeholder = "Tags"
        return textField
    }()

    let tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return collectionView
    }()

    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(.systemGray6, for: .normal)
        button.backgroundColor = .blue
        button.isEnabled = false
        button.layer.cornerRadius = 20
        //        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
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
