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
    let filteredQuotes: BehaviorRelay<[Quote]> = BehaviorRelay(value: [])
    let searchText: BehaviorRelay<String> = BehaviorRelay(value: "")
    let filteredTags: BehaviorRelay<Set<String>> = BehaviorRelay(value: [])
    let filteringTags: BehaviorRelay<Set<String>> = BehaviorRelay(value: [])
    let clearFilteringTags: PublishSubject<Void> = PublishSubject()

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

    func filterQuotesAndTags(by text: String) {
        if searchText.value == text {
            return
        }
        clearFilteringTags.onNext(())
        searchText.accept(text)
        if text.isEmpty {
            filteredTags.accept(allTags.value)
        } else {
            let filteredQuotes = self.allQuotes.value
            self.filteredQuotes.accept(filteredQuotes.filter {
                ($0.title + $0.quote + ($0.author ?? "") + $0.bookTitle)
                    .lowercased()
                    .removeWhitespace()
                    .contains(text.lowercased().removeWhitespace())})
            let tags = allTags.value
            self.filteredTags.accept(tags.filter {
                $0.lowercased().contains(text.lowercased())})
        }
    }

    func filterQuotesByTags(tags: Set<String>) {
        if filteringTags.value == tags {
            return
        }
        filteringTags.accept(tags)
    }
}
