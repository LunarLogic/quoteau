//
//  DrawView.swift
//  Quoteau
//
//  Created by Wiktor Górka on 18/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DrawView: UIView {

    let keyboardHidden: PublishSubject<Void> = PublishSubject()
    let intersectingPoints: BehaviorRelay<CGPoint> = BehaviorRelay(value: CGPoint())
    var points = [CGPoint]()
    var lines = [[CGPoint]]()
    var drawingEnabled = true

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard drawingEnabled else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(10)
        context.setStrokeColor(UIColor(white: 0.9, alpha: 0.3).cgColor)
        context.setLineCap(.round)

        lines.forEach { (line) in
            for (index, point) in line.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        }
        context.strokePath()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keyboardHidden.onNext(())
        guard drawingEnabled else { return }
        lines.append([CGPoint]())
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled else { return }
        guard let point = touches.first?.location(in: self),
              var lastLine = lines.popLast() else { return }
        points.append(point)
        lastLine.append(point)
        lines.append(lastLine)
        intersectingPoints.accept(point)
        setNeedsDisplay()
    }

    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
}
