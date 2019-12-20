//
//  QuoteauTests.swift
//  QuoteauTests
//
//  Created by Wiktor Górka on 18/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Quick
import Nimble
//import XCTest

@testable import Quoteau
class QuoteauTests: QuickSpec {

    override func spec() {
        var imageProcessor: ImageProcessor!

        beforeEach {
            imageProcessor = ImageProcessor()
        }

        describe("image processing") {
            context("read text from screen shot") {
                it("should transform image to text") {
                    let imageView = UIImageView(image: UIImage(named: "screenshot_for_test"))
                    waitUntil { done in
                        imageProcessor.process(in: imageView, singleWords: true) { (text, _) in

                            expect(text).to(equal("Writing beautiful, performant applications is"))
                            done()
                        }
                    }
                }
            }
        }
    }
}
