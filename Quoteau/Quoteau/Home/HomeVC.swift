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
    let tagCellId = "tagCellId"

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .quoteauViewControllerBackgroundColor
        setupConstraints()
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.delegate = nil
        collectionView.dataSource = nil
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
        setupBindingsAfterViewAppear()
        viewModel.getQuotes()
        viewModel.extractTags()
    }

    // MARK: - Bindings
    fileprivate func setupBindings() {
        viewModel.allQuotes
            .asObservable()
            .subscribe(onNext: { [weak self] quotes in
                self?.viewModel.filteredQuotes.accept(quotes)
            }).disposed(by: disposeBag)

        viewModel.emptyScreen
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyQuotesLabel.isHidden = false
                } else {
                    self?.collectionView.isHidden = false
                }
            }).disposed(by: disposeBag)

        viewModel.allTags
            .asObservable()
            .subscribe(onNext: { [weak self] tags in
                self?.viewModel.filteredTags.accept(tags)
            }).disposed(by: disposeBag)
    }

    fileprivate func setupBindingsAfterViewAppear() {
        viewModel.filteredQuotes
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                let indexSet: IndexSet = [2]
                self?.collectionView.reloadSections(indexSet)
            }).disposed(by: disposeBag)

        viewModel.filteredTags
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                let indexSet: IndexSet = [2]
                self?.collectionView.reloadSections(indexSet)
            }).disposed(by: disposeBag)

        viewModel.filteringTags
            .filter({$0 != []})
            .asObservable()
            .subscribe(onNext: { [weak self] selectedTags in
                guard let viewModel = self?.viewModel else { return }
                let quotes = viewModel.allQuotes.value.filter({ !Set($0.tags).isDisjoint(with: selectedTags)})

                viewModel.filteredQuotes.accept(quotes)
            }).disposed(by: disposeBag)

        viewModel.searchText
            .asObservable()
            .filter({ $0.isEmpty})
            .subscribe(onNext: { [weak self] _ in
                guard let viewModel = self?.viewModel else { return }
                viewModel.filteredQuotes.accept(viewModel.allQuotes.value)
            }).disposed(by: disposeBag)
    }

    // MARK: - Private
    fileprivate func setupCollectionView() {
        collectionView.register(QuoteCollectionViewCell.self,
                                forCellWithReuseIdentifier: quotesCellsId)
        collectionView.register(TagsCell.self, forCellWithReuseIdentifier: tagCellId)
        collectionView.register(SearchCollectionViewHeader.self,
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
        let attributedText = NSMutableAttributedString(
            string: "Oh hi there! Please, go ahead and \nadd your first quote.",
            attributes: [.font: UIFont.systemFont(ofSize: 19, weight: .regular)]
        )
        let secondSentense = NSAttributedString(
            string: "\nThis page is waiting for some cool\nquotes from you." ,
            attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .light)]
        )
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
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch indexPath.section {
        case 0:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: searchHeaderID,
                for: indexPath
            )
            as? SearchCollectionViewHeader
            else {
                fatalError("Unable to dequeue SearchTableViewHeader")
            }
            if !viewModel.searchText.value.isEmpty {
                header.searchText.accept(viewModel.searchText.value)
            }
            header.searchText
                .asObservable()
                .subscribe(onNext: { [weak self] text in
                    self?.viewModel.filterQuotesAndTags(by: text)
                }).disposed(by: disposeBag)

            return header
        case 1:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: titleHeaderId,
                for: indexPath
            )
            as? TitleCollectionViewHeader
            else {
                fatalError("Unable to dequeue TitleCollectionViewHeader")
            }
            header.titleLabel.text = "Recent tags:"
            return header
        case 2:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: titleHeaderId,
                for: indexPath
            )
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

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: view.frame.width, height: Constraints.searchHeaderHomeVCHeight)
        default:
            return CGSize(width: view.frame.width, height: Constraints.titlesHeadersHomeVCHeight)
        }
    }

    // MARK: - CollectionView Delegates and DataSource
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = DetailQuoteVC()
        let detailQuoteViewModel = DetailsQuoteViewModel()
        detailQuoteViewModel.quote.accept(viewModel.filteredQuotes.value[indexPath.item])
        controller.viewModel = detailQuoteViewModel
        present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
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
            return viewModel.filteredQuotes.value.count
        default:
            return 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch indexPath.section {
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: tagCellId,
                for: indexPath
            ) as? TagsCell
            else {
                fatalError("Unable to dequeue TagsCell")
            }
            viewModel.searchText
                .asObservable()
                .subscribe(onNext: {  _ in
                    // guard let viewModel = self?.viewModel else { return }
                    cell.selectedTags.accept([])
                }).disposed(by: disposeBag)

            viewModel.filteredTags
                .asObservable()
                .subscribe(onNext: { tags in
                    cell.allTags = Array(tags)
                }).disposed(by: disposeBag)

            viewModel.clearFilteringTags
                .subscribe(onNext: { _ in
                    cell.selectedTags.accept([])
                }).disposed(by: disposeBag)

            cell.selectedTags
                .asObservable()
                // .filter({ $0 != [] })
                .subscribe(onNext: { [weak self] tags in
                    self?.viewModel.filterQuotesByTags(tags: Set(tags))
                }).disposed(by: disposeBag)
            cell.allTags = Array(viewModel.filteredTags.value)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: quotesCellsId,
                for: indexPath
            ) as? QuoteCollectionViewCell
            else {
                fatalError("Unable to dequeue QuoteCollectionViewCell")
            }
            cell.quote = viewModel.filteredQuotes.value[indexPath.item]
            return cell
        default:
            fatalError("Unnkonw cells")
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
}
