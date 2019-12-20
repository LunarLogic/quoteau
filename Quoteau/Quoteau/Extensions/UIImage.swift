//
//  UIImage.swift
//  Quoteau
//
//  Created by Wiktor Górka on 19/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit

extension UIImage {

   private func transformImageOrientation() -> CGAffineTransform {
        let width  = self.size.width
        let height = self.size.height
         var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5*CGFloat.pi)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5*CGFloat.pi)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("unknown image orientation")
        }
        return transform
    }

    func straightenImageOrientation() -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        if imageOrientation == .up {
            return self
        }

        let width  = self.size.width
        let height = self.size.height
        let transform = UIImage.transformImageOrientation(self)

        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }

        guard let context = CGContext(data: nil,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else { return nil }

        context.concatenate(transform())

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0,
                                             y: 0,
                                             width: height,
                                             height: width))
        default:
            context.draw(cgImage, in: CGRect(x: 0,
                                             y: 0,
                                             width: width,
                                             height: height))
        }

        guard let newCGImg = context.makeImage() else { return nil }

        let img = UIImage(cgImage: newCGImg)

        return img
    }
}
