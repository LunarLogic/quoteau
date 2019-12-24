//
//  QuoteSelectionViewModel.swift
//  Quoteau
//
//  Created by Wiktor Górka on 23/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class QuoteSelectionViewModel {

    let disposeBag = DisposeBag()
    let processor = ImageProcessor()
    var drawView: DrawView?
    let frameSublayer: BehaviorRelay<CALayer> = BehaviorRelay(value: CALayer())
    let fullText: BehaviorRelay<[(text: String, index: Int)]> = BehaviorRelay(value: [])
    let points: BehaviorRelay<[CGPoint]> = BehaviorRelay(value: [])
    let allElement: BehaviorRelay<[TextElement]> = BehaviorRelay(value: [])
    let unchangedElements: BehaviorRelay<[TextElement]> = BehaviorRelay(value: [])
    let scannedText: PublishSubject<String> = PublishSubject()

    init(drawView: DrawView) {
        self.drawView = drawView

        drawView.intersectingPoints.asObservable()
            .subscribe(onNext: { [unowned self] point in

                for (index, element) in self.allElement.value.enumerated() {

                    if element.scaledElement.frame.contains(point) {
                        self.frameSublayer.value.addSublayer(element.scaledElement.selectedShapeLayer)
                        let oldText = self.fullText.value
                        let newText = oldText + [(text: element.text, index: element.index)]
                        let sortedNewtext = newText.sorted(by: {$0.index < $1.index })
                        self.fullText.accept(sortedNewtext)
                        let allElements = self.allElement.value
                        var removedSelectedElement = allElements
                        removedSelectedElement.remove(at: index)
                        self.allElement.accept(removedSelectedElement)
                    }
                }

            }).disposed(by: disposeBag)
    }

    private func removeFrames() {
        guard let sublayers = frameSublayer.value.sublayers else { return }
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
    }

    func drawFrames(in imageView: UIImageView, words: Bool, completion: (() -> Void)? = nil) {
        removeFrames()
        processor.process(in: imageView, singleWords: words)
            .subscribe(onNext: { [weak self] text, textElements  in
                self?.unchangedElements.accept(textElements)
                self?.allElement.accept(textElements)
                self?.points.accept([])
                for element in textElements.enumerated() {
                    self?.frameSublayer.value.addSublayer(element.element.scaledElement.shapeLayer)
                }
                self?.scannedText.onNext(text)
                completion?()
            }).disposed(by: disposeBag)
    }
}
