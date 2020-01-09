//
//  SaveQuoteViewModel.swift
//  Quoteau
//
//  Created by Wiktor Górka on 24/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SaveQuoteViewModel {

    let name: BehaviorRelay<String> = BehaviorRelay(value: "")
    let quote: BehaviorRelay<String> = BehaviorRelay(value: "")
    let bookTitle: BehaviorRelay<String> = BehaviorRelay(value: "")
    let author: BehaviorRelay<String> = BehaviorRelay(value: "")
    let tags: BehaviorRelay<String> = BehaviorRelay(value: "")

    func saveQuote() {

        let allTags = separateTags(string: tags.value)

        let quote = Quote(quote: self.quote.value,
                          title: name.value,
                          author: author.value,
                          tags: allTags,
                          bookTitle: bookTitle.value)

        LocalAPICommunicator.shared.saveQuote(quote: quote)
        RemoteAPICommunicator.shared.saveQuotesInFirestre(quotes: [quote]) { (result) in
            switch result {
            case .success:
                print("Saved quote in firestore")
            case .failure(let err):
                print(err)
            }
        }
    }

    fileprivate func separateTags(string: String) -> [String] {
        var tags = [String]()
        var word = ""

        for char in string {
            switch char {
            case "#":
                if !word.isEmpty {
                    tags.append(word)
                    word.removeAll()
                }
            case " ":
                break
            default:
                word.append(char)
            }
        }
        return tags + [word]
    }

    // MARK: - Submit Button State
    var submitButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(nameValid, bookTitleValid, quoteValid, tagsValid) { $0 && $1 && $2 && $3}
    }

    private var nameValid: Observable<Bool> {
        return name.asObservable().map { !$0.isEmpty }
    }

    private var bookTitleValid: Observable<Bool> {
        return bookTitle.asObservable().map { !$0.isEmpty }
    }

    private var quoteValid: Observable<Bool> {
        return quote.asObservable().map { !$0.isEmpty }
    }
    private var tagsValid: Observable<Bool> {
        return tags.asObservable().map { !$0.isEmpty }
    }
}
