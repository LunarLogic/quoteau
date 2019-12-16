//
//  QuoteSelectionViewController.swift
//  Quotes
//
//  Created by Wiktor Górka on 05/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import SnapKit

class QuoteSelectionViewController: UIViewController {
    
    var resultViewTopAnchor: Constraint?
    let processor = ImageProcessor()
    var frameSublayer = CALayer()
    var difference: CGFloat?
    let drawView = DrawView()
    var fullText = [(text: String, index: Int)]()
    var points = [CGPoint]()
    var allElement: [TextElement]?
    var unchangedElements = [TextElement]()
    var resultViewFrame: CGFloat?
    var scannedText: String = "Detected text can be edited here." {
        didSet {
            textView.text = scannedText
        }
    }
    
    //    MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(imageView.frame.height)
        view.backgroundColor = .white
        setupViews()
        setupNavigation()
        addSwipeGesture(view: strechResultViewButton)
        resultView.layoutIfNeeded()
        textView.alwaysBounceVertical = true
        imageView.layer.addSublayer(frameSublayer)
        drawFeatures(in: imageView, words: true)
        drawView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        difference = view.frame.maxY - imageView.frame.maxY
        resultViewFrame = resultView.frame.height
        
        guard let difference = difference else { return }
        
        resultView.snp.remakeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            if Int(difference) < 200 {
                self.resultViewTopAnchor = make.top.equalTo(imageView.snp.bottom).inset(100).constraint
            } else {
                self.resultViewTopAnchor = make.top.equalTo(imageView.snp.bottom).constraint
            }
        }
    }
    
    //     MARK:- Private
    @objc fileprivate func handleOpenCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        }
    }
    
    @objc fileprivate func handleOpenPhotos() {
        presentImagePickerController(withSourceType: .photoLibrary)
    }
    
    @objc fileprivate func handleSave() {
        
        let controller = NewQuoteViewController()
        controller.quoteText = textView.text
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func removeFrames() {
        guard let sublayers = frameSublayer.sublayers else { return }
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
    }
    
    private func drawFeatures(in imageView: UIImageView, words: Bool, completion: (() -> Void)? = nil) {
        removeFrames()
        processor.process(in: imageView, singleWords: words) { text, elements, textElements  in
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
        
        guard let difference = difference else { return }
        
        if resultView.frame.height < difference + 30 ||  resultView.frame.height == 200 {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.strechResultViewButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                
                self.resultViewTopAnchor?.update(inset: 400)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.strechResultViewButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                self.resultViewTopAnchor?.update(inset: 0)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
    @objc fileprivate func handleStrech(sender: UIPanGestureRecognizer) {
        guard let difference = difference else { return }
        guard let resultViewFrame = resultViewFrame else { return }
        resultViewTopAnchor?.deactivate()
//        print(resultView.frame.height)
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
            print(view.frame.maxY - sender.location(in: view).y)
                       print(difference)
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
    
    
    //    MARK:- Navigation
    fileprivate func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Photo", style: .plain, target: self, action: #selector(handleOpenPhotos))
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem.init(title: "Camera", style: .plain, target: self, action: #selector(handleOpenCamera))]
    }
    
    //    MARK:- Views
    
    let strechResultViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.addTarget(self, action: #selector(handleFastStrech), for: .touchUpInside)
        return button
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray4
        iv.image = UIImage(systemName: "photo.on.rectangle")
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let resultView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .systemGray5
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    //    MARK:- Constraints
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

// MARK:- Extension
extension QuoteSelectionViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate, NewLineDelgate {
    func didAddNewLine(point: CGPoint) {
        points.append(point)
        
        if let allElement = allElement {
            for (index, element) in allElement.enumerated() {
                
                if self.points.first(where: { element.scaledElement.frame.contains($0) } ) != nil {
                    
                    self.frameSublayer.addSublayer(element.scaledElement.selectedShapeLayer)
//                    print(element.text)
                    
                    fullText.append((element.text, element.index))
                    self.allElement?.remove(at: index)
                }
            }
            
            fullText.sort(by: {$0.index < $1.index })
            
            self.textView.text = fullText.reduce("") { $0 + " " + $1.text}
        }
    }
    
    private func presentImagePickerController(withSourceType sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage =
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.contentMode = .scaleAspectFit
            let fixedImage = pickedImage.fixOrientation()
            imageView.image = fixedImage
            drawFeatures(in: imageView, words: true)
        }
        dismiss(animated: true, completion: nil)
    }
}






extension UIImage {
    
    func fixOrientation() -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        
        if imageOrientation == .up {
            return self
        }
        
        let width  = self.size.width
        let height = self.size.height
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5*CGFloat.pi)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5*CGFloat.pi)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError()
        }
        
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        
        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else {
                return nil
        }
        
        context.concatenate(transform);
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let newCGImg = context.makeImage() else {
            return nil
        }
        
        let img = UIImage(cgImage: newCGImg)
        
        return img
    }
}
