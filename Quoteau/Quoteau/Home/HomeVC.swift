//
//  HomeVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 24/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeVC: UIViewController {

    let viewModel = HomeViewModel()
    var disposeBag = DisposeBag()
    let quotesCellsId = "quotesCellsId"
    let searchHeaderID = "searchHeaderId"
    let titleHeaderId = "titleHeaderId"

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupConstraints()
        setupBindings()
        viewModel.getQuotes()
        setupCollectionView()
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Bindings
    fileprivate func setupBindings() {
        viewModel.allQuotes
            .asObservable()
            .subscribe(onNext: { quotes in
                // quotes for collection view
                print(quotes)
            }).disposed(by: disposeBag)

        viewModel.emptyScreen
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyQuotesLabel.isHidden = false
                } else {
                    self?.collectionView.isHidden = false
                }
            }).disposed(by: disposeBag)
    }

    // MARK: - Private
    fileprivate func setupCollectionView() {
        collectionView.register(QuoteCollectionViewCell.self,
                                forCellWithReuseIdentifier: quotesCellsId)
        collectionView.register(SearchTableViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: searchHeaderID)
        collectionView.register(TitleCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: titleHeaderId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .interactive
    }

    // MARK: - Views
    let emptyQuotesLabel: UILabel = {
        let label = UILabel()
        let attributedText =
            NSMutableAttributedString(string: "Oh hi there! Please, go ahead and \nadd your first quote.",
                                      attributes: [.font: UIFont.systemFont(ofSize: 19,
                                                                            weight: .regular)])
        let secondSentense = NSAttributedString(string: "\nThis page is waiting for some cool\nquotes from you." ,
                                                attributes: [.font: UIFont.systemFont(ofSize: 13,
                                                                                      weight: .light)])
        attributedText.append(secondSentense)
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.backgroundColor = .systemGray6
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    // MARK: - Constraints
    fileprivate func setupConstraints() {
        view.addSubview(emptyQuotesLabel)
        emptyQuotesLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Headers
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case 0:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: searchHeaderID,
                                                                               for: indexPath) as? SearchTableViewHeader
                else {
                    fatalError("Unable to dequeue SearchTableViewHeader")
            }
            return header
        case 1:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: titleHeaderId,
                                                                               for: indexPath)
                as? TitleCollectionViewHeader
                else {
                    fatalError("Unable to dequeue TitleCollectionViewHeader")
            }
            header.titleLabel.text = "Recent tags:"
            return header
        case 2:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: titleHeaderId,
                                                                               for: indexPath)
                as? TitleCollectionViewHeader
                else {
                    fatalError("Unable to dequeue TitleCollectionViewHeader")

            }
            header.titleLabel.text = "Recent quotes:"
            return header
        default:
            fatalError("Unknown section")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: view.frame.width, height: Constraints.searchHeaderHomeVCHeight)
        default:
            return CGSize(width: view.frame.width, height: Constraints.titlesHeadersHomeVCHeight)
        }
    }

    // MARK: - CollectionView Delegates and DataSource
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        switch indexPath.section {
        case 1:
            return CGSize(width: view.frame.width, height: Constraints.tagsCollectionViewHeight)
        case 2:
            return CGSize(width: view.frame.width, height: Constraints.quoteCellHeight)
        default:
            fatalError("Unknown cell")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return 1
        case 2:
            return 10
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 1:
            // Future tags collectionView
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: quotesCellsId,
                                                                for: indexPath) as? QuoteCollectionViewCell
                else {
                    fatalError("Unable to dequeue QuoteCollectionViewCell")
            }
            cell.quoteLabel.text = ""
            cell.quoteTitleLabel.text = "(Tags in future)"
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: quotesCellsId,
                                                                for: indexPath) as? QuoteCollectionViewCell
                else {
                    fatalError("Unable to dequeue QuoteCollectionViewCell")
            }
            return cell
        default:
            fatalError("Unnkonw cells")
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
}
