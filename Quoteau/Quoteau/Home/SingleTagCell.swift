//
//  SingleTagCell.swift
//  Quoteau
//
//  Created by Wiktor Górka on 07/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit

class SingleTagCell: UICollectionViewCell {

    var tagtext: String? {
        didSet {
            guard let tag = tagtext else { return }
            tagLabel.text = tag
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tagLabel)
        tagLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
}
