//
//  SearchTableViewHeader.swift
//  Quoteau
//
//  Created by Wiktor Górka on 25/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit

class SearchTableViewHeader: UICollectionViewCell {

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
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
