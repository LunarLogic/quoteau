//
//  TextView.swift
//  Quotes
//
//  Created by Wiktor Górka on 05/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit


protocol NewLineDelgate {
    func didAddNewLine(point: CGPoint)
}

class DrawView: UIView {
    
    var delegate: NewLineDelgate?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
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
    
    var points = [CGPoint]()
    
    //  var lines = [CGPoint]()
    
    var lines = [[CGPoint]]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
        
        //    guard let point = touches.first?.location(in: nil) else { return }
        //    print(point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: self) else { return }
//        print(point)
        points.append(point)
        
        guard var lastLine = lines.popLast() else { return }
        lastLine.append(point)
        lines.append(lastLine)
        delegate?.didAddNewLine(point: point)
        
        setNeedsDisplay()
    }
    
    
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
}
