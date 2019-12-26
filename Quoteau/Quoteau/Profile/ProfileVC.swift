//
//  ProfileVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 26/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit

class ProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupConstraint()
        navigationItem.title = "User name"
    }

    // MARK: - Views
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In / Log out", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 22
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
