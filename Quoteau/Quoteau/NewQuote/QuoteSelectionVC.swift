//
//  QuoteSelectionVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 18/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class QuoteSelectionVC: UIViewController {

    var viewModel: QuoteSelectionViewModel?
    let disposeBag = DisposeBag()
    var keyboardSize: CGFloat?
    var resultViewTopAnchor: Constraint?
    var spaceForResultView: CGFloat?
    var resultViewFrame: CGFloat?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = QuoteSelectionViewModel(drawView: drawView)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        }

        view.backgroundColor = .systemGray6
        setupViews()
        setupBinding()
        setupNavigation()
        setupKeyboardNotifications()
        addSwipeGesture(view: strechResultViewButton)
        resultView.layoutIfNeeded()
        textView.alwaysBounceVertical = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        spaceForResultView = view.frame.maxY - imageView.frame.maxY
        resultViewFrame = resultView.frame.height

        guard let spaceForResultView = spaceForResultView else { return }
        resultView.snp.remakeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            if Int(spaceForResultView) < Constraints.smallestHeightForTextView {
                self.resultViewTopAnchor = make.top.equalTo(imageView.snp.bottom).inset(100).constraint
            } else {
                self.resultViewTopAnchor = make.top.equalTo(imageView.snp.bottom).constraint
            }
        }
    }

    // MARK: - Bindings
    fileprivate func setupBinding() {
        guard let viewModel = viewModel else { return }

        viewModel.drawFrames(in: imageView, words: true)

        viewModel.frameSublayer
            .asObservable()
            .subscribe(onNext: { [weak self] layer in
                DispatchQueue.main.async {
                    self?.imageView.layer.addSublayer(layer)
                }
            }).disposed(by: disposeBag)

        viewModel.scannedText
            .subscribe(onNext: { [weak self] text in
            DispatchQueue.main.async {
                self?.textView.text = text
            }
        }).disposed(by: disposeBag)

        viewModel.fullText
            .asObservable()
            .subscribe(onNext: { [weak self] text in
                DispatchQueue.main.async {
                    self?.textView.text = text.reduce("") { $0 + " " + $1.text }
                }
            }).disposed(by: disposeBag)

        drawView.keyboardHidden
            .subscribe(onNext: { [weak self] _ in
                self?.textView.resignFirstResponder()
            }).disposed(by: disposeBag)
    }

    // MARK: - Private
    @objc fileprivate func handleOpenCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        }
    }

    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func handleSave() {

    }
    // MARK: - Stretchy View
    fileprivate func addSwipeGesture(view: UIView) {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStrech(sender:)))
        view.addGestureRecognizer(swipeGesture)
    }

    @objc fileprivate func handleFastStrech() {
        guard let spaceForResultView = spaceForResultView else { return }

        if resultView.frame.height < spaceForResultView + 30 ||  resultView.frame.height == 200 {
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 2,
                           options: .curveEaseOut,
                           animations: {
                            self.strechResultViewButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)

                            self.resultViewTopAnchor?.update(inset: 400)
                            self.view.layoutIfNeeded()
            }, completion: nil)

        } else {
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 2,
                           options: .curveEaseOut,
                           animations: {
                            self.strechResultViewButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                            self.resultViewTopAnchor?.update(inset: 0)
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc fileprivate func handleStrech(sender: UIPanGestureRecognizer) {
        guard let difference = spaceForResultView else { return }
        guard let resultViewFrame = resultViewFrame else { return }
        resultViewTopAnchor?.deactivate()
        view.layoutIfNeeded()
        switch sender.state {
        case .began:
            print()
        case .changed:
            let position = view.frame.maxY - sender.location(in: view).y
                - resultViewFrame

            if view.frame.maxY - sender.location(in: view).y > difference {
                resultViewTopAnchor?.update(inset: position)
                view.layoutIfNeeded()
            }

            strechResultViewButton.setImage(UIImage(systemName: "minus"), for: .normal)

        case .ended:
            resultViewTopAnchor?.activate()
            if (view.frame.maxY - sender.location(in: view).y) < difference + 30 {
                strechResultViewButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            } else {
                strechResultViewButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            }
        default:
            print()
        }
        resultViewTopAnchor?.activate()
    }

    // MARK: - Keyboard slide up
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]
            as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                drawView.drawingEnabled = false
                view.frame.origin.y -= keyboardSize.height
                self.keyboardSize = keyboardSize.height
                strechResultViewButton.isHidden = true

                if resultView.frame.height + keyboardSize.height + 150 > view.frame.height {
                    self.resultViewTopAnchor?.update(inset: 0)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y += self.keyboardSize ?? 0.0
            strechResultViewButton.isHidden = false
            drawView.drawingEnabled = true
        }
    }

    // MARK: Keyboard Notifications
    fileprivate func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // MARK: - Navigation
    fileprivate func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Cancel",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(handleCancel))

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(handleSave))]
    }

    // MARK: - Views

    let drawView = DrawView()

    let strechResultViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.addTarget(self, action: #selector(handleFastStrech), for: .touchUpInside)
        return button
    }()

    let imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()

    let resultView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemGray6
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()

    // MARK: - Constraints
    fileprivate func setupViews() {

        let viewWidth = view.frame.width

        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp_topMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(viewWidth*4/3)
        }

        view.addSubview(resultView)
        resultView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            self.resultViewTopAnchor = make.top.equalTo(imageView.snp.bottom).constraint
        }

        resultView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.bottom.trailing.leading.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }

        resultView.addSubview(strechResultViewButton)
        strechResultViewButton.snp.makeConstraints { (make) in
            make.trailing.leading.top.equalToSuperview()
            make.bottom.equalTo(textView.snp.top)
        }

        view.addSubview(drawView)
        drawView.backgroundColor = .clear

        drawView.snp.makeConstraints { (make) in
            make.edges.equalTo(imageView)
        }

        view.bringSubviewToFront(resultView)
    }
}

// MARK: - Extensions
extension QuoteSelectionVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private func presentImagePickerController(withSourceType sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        present(controller, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerController Delegate

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.contentMode = .scaleAspectFit
            let fixedImage = pickedImage.straightenImageOrientation()
            imageView.image = fixedImage
            viewModel?.drawFrames(in: imageView, words: true)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
