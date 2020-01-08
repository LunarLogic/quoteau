//
//  QuoteCollectionViewCell.swift
//  Quoteau
//
//  Created by Wiktor Górka on 25/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit

class QuoteCollectionViewCell: UICollectionViewCell {

    var quote: Quote? {
        didSet {
            guard let quote = quote else { return }
            quoteLabel.text = quote.quote
            quoteTitleLabel.text = quote.title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var stackView = UIStackView(arrangedSubviews: [quoteTitleLabel, quoteLabel])

    let quoteTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    let quoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.numberOfLines = 0
        return label
    }()
}
