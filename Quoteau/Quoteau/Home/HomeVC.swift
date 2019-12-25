//
//  HomeVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 24/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeVC: UIViewController {

    let viewModel = HomeViewModel()
    var disposeBag = DisposeBag()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupConstraints()
        setupBindings()
        viewModel.getQuotes()
    }

    // MARK: - Bindings
    fileprivate func setupBindings() {
        viewModel.allQuotes
            .asObservable()
            .subscribe(onNext: { quotes in
                // quotes for collection view
                print(quotes)
            }).disposed(by: disposeBag)

        viewModel.emptyScreen
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyQuotesLabel.isHidden = false
                }
            }).disposed(by: disposeBag)
    }

    // MARK: - Views
    let emptyQuotesLabel: UILabel = {
        let label = UILabel()
        let attributedText =
            NSMutableAttributedString(string: "Oh hi there! Please, go ahead and \n add your first quote.",
                                      attributes: [.font: UIFont.systemFont(ofSize: 19,
                                                                            weight: .regular)])
        let secondSentense = NSAttributedString(string: "\nThis page is waiting for some cool\n quotes from you." ,
                                                attributes: [.font: UIFont.systemFont(ofSize: 13,
                                                                                      weight: .light)])
        attributedText.append(secondSentense)
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Constraints
    fileprivate func setupConstraints() {
        view.addSubview(emptyQuotesLabel)
        emptyQuotesLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
