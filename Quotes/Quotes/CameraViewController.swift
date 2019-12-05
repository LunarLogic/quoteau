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
            print()
        case .changed:
            if view.frame.maxY - sender.location(in: view).y > difference {
                resultViewHeight.constant = view.frame.maxY - sender.location(in: view).y
            }
            
            strechResultViewButton.setImage(UIImage(systemName: "minus"), for: .normal)
        case .ended:
            
            if resultViewHeight.constant < view.frame.maxY - imageView.frame.maxY + 30 {
                strechResultViewButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            } else {
                strechResultViewButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            }
        default:
            print()
        }
    }
    
    
    
    @IBAction func strechViewButonSlide(_ sender: UIButton) {
        
        if resultViewHeight.constant < view.frame.maxY - imageView.frame.maxY + 30 {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.strechResultViewButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                self.resultViewHeight.constant = self.view.frame.maxY - 150
                
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            if difference < 200 {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                    self.strechResultViewButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                    self.resultViewHeight.constant = 200
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                    self.strechResultViewButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                    self.resultViewHeight.constant = self.view.frame.maxY - self.imageView.frame.maxY
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            
        }
        
        
        
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
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage =
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}

