//
//  ViewController.swift
//  Quotes
//
//  Created by Wiktor Górka on 25/11/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var strechResultViewButton: UIButton!
    @IBOutlet weak var resultViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultView: UIView!
    
    lazy var difference = view.frame.maxY - imageView.frame.maxY
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSwipeGesture(view: strechResultViewButton)
        
        if difference < 200 {
            resultViewHeight.constant = 200
        } else {
            resultViewHeight.constant = view.frame.maxY - imageView.frame.maxY
        }
        
        resultView.layoutIfNeeded()
    }
    
    func addSwipeGesture(view: UIView) {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraViewController.handleStrech(sender:)))
        view.addGestureRecognizer(swipeGesture)
    }
    
    
    @objc func handleStrech(sender: UIPanGestureRecognizer) {
        
        resultView.layoutIfNeeded()
        switch sender.state {
        case .began:
            
            resultViewHeight.constant = view.frame.maxY - sender.location(in: view).y
        case .changed:
            print()
            resultViewHeight.constant = view.frame.maxY - sender.location(in: view).y
        case .ended:
            print()
        default:
            print(sender.state.rawValue)
            print()
        }
    }
    
    
    
    @IBAction func strechViewButonSlide(_ sender: UIButton) {
        //        resultViewHeight.constant = 600
        //        resultView.layoutIfNeeded()
    }
    
    
    @IBAction func photosButtonTapped(_ sender: Any) {
        presentImagePickerController(withSourceType: .photoLibrary)
    }
    
    
    
    @IBAction func scanButtonTapped(_ sender: Any) {
        
        
        
    }
    
    
    
    @IBAction func CameraButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        }
    }
    
    
    
    
    
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private func presentImagePickerController(withSourceType sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        //       controller.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage =
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.contentMode = .scaleAspectFit
            //         let fixedImage = pickedImage.fixOrientation()
            imageView.image = pickedImage
            //         drawFeatures(in: imageView, words: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}

