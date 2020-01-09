//
//  TagsCell.swift
//  Quoteau
//
//  Created by Wiktor Górka on 07/01/2020.
//  Copyright © 2020 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TagsCell: UICollectionViewCell {

    var selectedTags: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    var allTags: [String]? {
        didSet {
            selectedTags.accept([])
            collectionView.reloadData()
        }
    }
    let singleTagCellId = "singleTagCellId"

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        backgroundColor = .systemGray6
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SingleTagCell.self, forCellWithReuseIdentifier: singleTagCellId)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGray6
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
}

// MARK: - Delegates
extension TagsCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTags?.count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: frame.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: singleTagCellId,
                                                            for: indexPath) as? SingleTagCell
            else {
                fatalError("Unable to dequeue QuoteCollectionViewCell")
        }
        cell.tagtext = allTags?[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)

        if cell?.isSelected == true {
            if let allTags = allTags {
                selectedTags.accept(selectedTags.value + [allTags[indexPath.item]])
            }
        }
    }
}
