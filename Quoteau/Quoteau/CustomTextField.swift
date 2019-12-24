//
//  CustomTextField.swift
//  Quoteau
//
//  Created by Wiktor Górka on 24/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    let padding: CGFloat

    init(padding: CGFloat) {
        self.padding = padding
        super.init(frame: .zero)
        layer.cornerRadius = 20
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1.4
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 44)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
