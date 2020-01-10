//
//  TagsSingleQuoteCell.swift
//  Quoteau
//
//  Created by Wiktor Górka on 10/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit

class TagsSingleQuoteCell: UICollectionViewCell {

    var tagText: String? {
        didSet {
            guard let tagText = tagText else { return }
            tagLabel.text = tagText
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tagLabel)
        tagLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        backgroundColor = .systemGray5
        layer.cornerRadius = 7
    }

    let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
