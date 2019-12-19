//
//  QuoteSelectionVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 18/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit

class QuoteSelectionVC: UIViewController {

    let processor = ImageProcessor()
    let frameSublayer = CALayer()

    var resultViewTopAnchor: Constraint?
    var spaceForResultView: CGFloat?
    var resultViewFrame: CGFloat?

    var fullText = [(text: String, index: Int)]()
    var points = [CGPoint]()
    var allElement: [TextElement]?
    var unchangedElements = [TextElement]()

    var scannedText: String? {
        didSet {
            textView.text = scannedText
        }
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        }

        view.backgroundColor = .systemGray6
        setupViews()
        setupNavigation()
        addSwipeGesture(view: strechResultViewButton)
        resultView.layoutIfNeeded()
        textView.alwaysBounceVertical = true
        imageView.layer.addSublayer(frameSublayer)
        drawFrames(in: imageView, words: true)
        drawView.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

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

    private func removeFrames() {
        guard let sublayers = frameSublayer.sublayers else { return }
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
    }

    private func drawFrames(in imageView: UIImageView, words: Bool, completion: (() -> Void)? = nil) {
        removeFrames()
        processor.process(in: imageView, singleWords: words) { text, textElements  in
            self.unchangedElements = textElements
            self.allElement = textElements
            self.points.removeAll()
            self.fullText.removeAll()
            self.drawView.clear()

            for element in textElements.enumerated() {
                self.frameSublayer.addSublayer(element.element.scaledElement.shapeLayer)
            }

            self.scannedText = text
            completion?()
        }
    }

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

    var keyboardSize: CGFloat?

    // MARK: - Keyboard slide up
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]
            as? NSValue)?.cgRectValue {
            drawView.drawingDisabled = true
            view.frame.origin.y -= keyboardSize.height
            self.keyboardSize = keyboardSize.height
            strechResultViewButton.isHidden = true

            if resultView.frame.height + keyboardSize.height + 150 > view.frame.height {
                self.resultViewTopAnchor?.update(inset: 0)
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y += self.keyboardSize ?? 0.0
        strechResultViewButton.isHidden = false
        drawView.drawingDisabled = false
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

// MARK: - Extension
extension QuoteSelectionVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate, NewLineDelgate {
    func hideKeybord() {
        textView.resignFirstResponder()
    }

    func didAddNewLine(point: CGPoint) {
        points.append(point)

        if let allElement = allElement {
            for (index, element) in allElement.enumerated() {

                if self.points.first(where: { element.scaledElement.frame.contains($0) }) != nil {

                    self.frameSublayer.addSublayer(element.scaledElement.selectedShapeLayer)

                    fullText.append((element.text, element.index))
                    self.allElement?.remove(at: index)
                }
            }
            fullText.sort(by: {$0.index < $1.index })
            self.textView.text = fullText.reduce("") { $0 + " " + $1.text }
        }
    }

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
            let fixedImage = pickedImage.fixOrientation()
            imageView.image = fixedImage
            drawFrames(in: imageView, words: true)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
