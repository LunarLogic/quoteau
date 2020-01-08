//
//  HomeViewModel.swift
//  Quoteau
//
//  Created by Wiktor Górka on 24/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

class HomeViewModel {

    let allQuotes: BehaviorRelay<[Quote]> = BehaviorRelay(value: [])
    let emptyScreen: PublishSubject<Bool> = PublishSubject()
    let allTags: BehaviorRelay<Set<String>> = BehaviorRelay(value: [])

    func getQuotes() {
        allQuotes.accept([])
        var quotes = [Quote]()
        LocalAPICommunicator.shared.readAllQuotes()?.forEach({ (quote) in
            quotes.append(quote)
        })

        if quotes.isEmpty {
            emptyScreen.onNext(true)
        } else {

            emptyScreen.onNext(false)
            allQuotes.accept(quotes)
        }
    }

    func extractTags() {
        allQuotes.value.forEach { (quote) in
            quote.tags.forEach { (tag) in
                var tags = self.allTags.value
                tags.insert(tag)
                self.allTags.accept(tags)
            }
        }
    }
}
