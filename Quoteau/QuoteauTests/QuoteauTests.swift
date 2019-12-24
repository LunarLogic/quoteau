//
//  QuoteauTests.swift
//  QuoteauTests
//
//  Created by Wiktor Górka on 18/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Quick
import Nimble
import RxSwift

@testable import Quoteau
class QuoteauTests: QuickSpec {

    let disposeBag = DisposeBag()
    let imageView = UIImageView(image: UIImage(named: "screenshot_for_test"))
    let defaultScaledElement = ScaledElement(frame: .zero,
                                             shapeLayer: CALayer(),
                                             selectedShapeLayer: CALayer())

    override func spec() {
        var imageProcessor: ImageProcessor?

        beforeEach {
            imageProcessor = ImageProcessor()
        }

        wholeLinesFromImage(imageProcessor: imageProcessor ?? ImageProcessor(),
                            imageView: imageView,
                            scaledElement: defaultScaledElement)
        singleWordsFromImage(imageProcessor: imageProcessor ?? ImageProcessor(),
                             imageView: imageView,
                             scaledElement: defaultScaledElement)

    }

    func wholeLinesFromImage(imageProcessor: ImageProcessor, imageView: UIImageView, scaledElement: ScaledElement) {
        describe("image processing") {
            context("read text lines from screen shot") {
                it("should transform image to text") {
                    waitUntil { done in

                        imageProcessor.process(in: imageView, singleWords: false)
                            .asObservable()
                            .subscribe(onNext: { (text, wordsFromLines) in
                            let textInLine = (TextElement(text: "Writing beautiful, performant applications is",
                                                          scaledElement: scaledElement,
                                                          index: 0))
                            expect(wordsFromLines).to(equal([textInLine]))
                            expect(text).to(equal("Writing beautiful, performant applications is"))
                            done()
                            }).disposed(by: self.disposeBag)
                    }
                }
            }
        }
    }

    func singleWordsFromImage(imageProcessor: ImageProcessor, imageView: UIImageView, scaledElement: ScaledElement) {

        describe("image processing") {
            context("single words") {
                it("should transfor image into single words") {
                    waitUntil { done in

                        imageProcessor.process(in: imageView, singleWords: true)
                        .asObservable()
                            .subscribe(onNext: { (text, singleWords) in

                            let firstWord = (TextElement(text: "Writing",
                                                         scaledElement: scaledElement,
                                                         index: 0))
                            let secondWord = (TextElement(text: "beautiful,",
                                                          scaledElement: scaledElement,
                                                          index: 1))
                            let thirdWord = (TextElement(text: "performant",
                                                         scaledElement: scaledElement,
                                                         index: 2))
                            let fourthWord = (TextElement(text: "applications",
                                                          scaledElement: scaledElement,
                                                          index: 3))
                            let fifthWord = (TextElement(text: "is",
                                                         scaledElement: scaledElement,
                                                         index: 4))
                            let textElementsToCompare = [firstWord,
                                                         secondWord,
                                                         thirdWord,
                                                         fourthWord,
                                                         fifthWord]

                            expect(singleWords).to(equal(textElementsToCompare))

                            expect(text).to(equal("Writing beautiful, performant applications is"))
                            done()

                            }).disposed(by: self.disposeBag)
                    }
                }
            }
        }
    }
}
