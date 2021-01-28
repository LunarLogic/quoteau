//
//  ImageProcessor.swift
//  Quoteau
//
//  Created by Wiktor Górka on 18/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import RxSwift
import MLKit

struct TextElement: Equatable {
    static func == (lhs: TextElement, rhs: TextElement) -> Bool {
        return lhs.text == rhs.text && lhs.index == rhs.index
    }

    let text: String
    let scaledElement: ScaledElement
    let index: Int
}

struct ScaledElement {
    let frame: CGRect
    let shapeLayer: CALayer
    let selectedShapeLayer: CALayer
}

class ImageProcessor {

    var textRecognizer: TextRecognizer!

    init() {
        textRecognizer = TextRecognizer.textRecognizer()
    }

    func process(in imageView: UIImageView, singleWords: Bool) -> Observable<(String, [TextElement])> {

        return Observable<(String, [TextElement])>.create { observer in

            self.process(in: imageView, singleWords: singleWords) { (text, textElement) in
                observer.onNext((text, textElement))
            }
            return Disposables.create()
        }
    }

    private func process(
        in imageView: UIImageView,
        singleWords: Bool,
        callback: @escaping (_ text: String, _ textElement: [TextElement]) -> Void
    ) {
        guard let image = imageView.image else { return }
        let visionImage = VisionImage(image: image)

        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result, !result.text.isEmpty else {
                callback("", [])
                return
            }

            var textElements = [TextElement]()
            var scaledElements: [ScaledElement] = []
            var index = 0

            if singleWords {
                for block in result.blocks {
                    for line in block.lines {
                        for element in line.elements {
                            let frame = self.createScaledFrame(featureFrame: element.frame,
                                                               imageSize: image.size,
                                                               viewFrame: imageView.frame)

                            let shapeLayer = self.createShapeLayer(frame: frame)
                            let selectedShapeLayer = self.editShapeLayer(frame: frame)
                            let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer,
                                                              selectedShapeLayer: selectedShapeLayer)
                            scaledElements.append(scaledElement)
                            textElements.append(TextElement(text: element.text,
                                                            scaledElement: scaledElement,
                                                            index: index))
                            index += 1
                        }
                    }
                }
            } else {
                for block in result.blocks {
                    for line in block.lines {

                        let frame = self.createScaledFrame(
                            featureFrame: line.frame, imageSize: image.size, viewFrame: imageView.frame
                        )
                        let shapeLayer = self.createShapeLayer(frame: frame)
                        let selectedShapeLayer = self.editShapeLayer(frame: frame)
                        let scaledElement = ScaledElement(
                            frame: frame, shapeLayer: shapeLayer, selectedShapeLayer: selectedShapeLayer
                        )
                        scaledElements.append(scaledElement)
                        textElements.append(TextElement(text: line.text, scaledElement: scaledElement, index: index))
                        index += 1

                    }
                }
            }
            callback(result.text, textElements)
        }
    }

    private func editShapeLayer(frame: CGRect) -> CAShapeLayer {
        let bpath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bpath.cgPath
        shapeLayer.strokeColor = Constants.editedLineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        return shapeLayer
    }

    private func createShapeLayer(frame: CGRect) -> CAShapeLayer {
        let bpath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bpath.cgPath
        shapeLayer.strokeColor = Constants.lineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        return shapeLayer
    }

    private func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
        let viewSize = viewFrame.size

        let resolutionView = viewSize.width / viewSize.height
        let resolutionImage = imageSize.width / imageSize.height

        var scale: CGFloat
        if resolutionView > resolutionImage {
            scale = viewSize.height / imageSize.height
        } else {
            scale = viewSize.width / imageSize.width
        }

        let featureWidthScaled = featureFrame.size.width * scale
        let featureHeightScaled = featureFrame.size.height * scale

        let imageWidthScaled = imageSize.width * scale
        let imageHeightScaled = imageSize.height * scale
        let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2

        let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
        let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale

        return CGRect(x: featurePointXScaled,
                      y: featurePointYScaled,
                      width: featureWidthScaled,
                      height: featureHeightScaled)
    }

    // MARK: - private

    private enum Constants {
        static let lineWidth: CGFloat = 1.7
        static let lineColor = UIColor.yellow.cgColor
        static let fillColor = UIColor.clear.cgColor
        static let editedLineColor = UIColor.blue.cgColor
    }
}
