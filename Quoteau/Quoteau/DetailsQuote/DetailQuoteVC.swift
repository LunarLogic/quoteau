//
//  DetailQuoteVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 10/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class DetailQuoteVC: UIViewController {

    private let tagCellId = "tagCellId"
    var viewModel: DetailsQuoteViewModel?
    let disposeBag = DisposeBag()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .quoteauViewControllerBackgroundColor
        navigationController?.navigationBar.isHidden = true
        setupConstraints()
        setupTagsCollectionView()
        setupBindings()
    }

    // MARK: - Bindings
    fileprivate func setupBindings() {
        guard let viewModel = viewModel else { return }
        viewModel.quote
            .asObservable()
            .subscribe(onNext: { [weak self] quote in
                self?.quoteLabel.text = quote.quote
                self?.titleLabel.text = quote.title
                self?.bookTitleAndAuthorLabel.text = "\(quote.bookTitle)\n\(quote.author ?? "")"
                viewModel.tags.accept(Array(quote.tags))
            }).disposed(by: disposeBag)

        viewModel.tags
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.tagsCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }

    // MARK: - Private
    fileprivate func setupTagsCollectionView() {
        tagsCollectionView.register(TagsSingleQuoteCell.self,
                                    forCellWithReuseIdentifier: tagCellId)
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
    }

    // MARK: - Views
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                       quoteLabel,
                                                       bookTitleAndAuthorLabel,
                                                       tagsLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 22
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    let quoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        return label
    }()

    let bookTitleAndAuthorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    let tagsLabel: UILabel = {
        let label = UILabel()
        label.text = "Tags:"
        return label
    }()

    let tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    // MARK: - Constraints
    fileprivate func setupConstraints() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(45)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        view.addSubview(tagsCollectionView)
        tagsCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - Collection View Delegates and Data Source
extension DetailQuoteVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel?.tags.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId,
                                                            for: indexPath) as? TagsSingleQuoteCell
            else {
                fatalError("Unable to dequeue TagsCell")
        }
        cell.tagText = viewModel?.tags.value[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 24)/2 - 10, height: 44)
    }
}
