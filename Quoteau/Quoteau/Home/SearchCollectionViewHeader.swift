//
//  SearchTableViewHeader.swift
//  Quoteau
//
//  Created by Wiktor Górka on 25/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SearchCollectionViewHeader: UICollectionViewCell {

    let disposeBag = DisposeBag()
    let searchText: BehaviorRelay<String> = BehaviorRelay(value: "")

    let searchTextField: CustomTextField = {
        let textField = CustomTextField(padding: 12)
        textField.placeholder = "Search here"
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        addSubview(searchTextField)
        searchTextField.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(12)
        }

        bind(textField: searchTextField, to: searchText)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
