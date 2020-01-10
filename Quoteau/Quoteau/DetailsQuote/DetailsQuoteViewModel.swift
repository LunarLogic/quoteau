//
//  DetailsQuoteViewModel.swift
//  Quoteau
//
//  Created by Wiktor Górka on 10/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class DetailsQuoteViewModel {
    var quote: BehaviorRelay<Quote> = BehaviorRelay(value: Quote())
    var tags: BehaviorRelay<[String]> = BehaviorRelay(value: [])
}
