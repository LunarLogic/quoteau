//
//  TabBarVC.swift
//  Quoteau
//
//  Created by Wiktor Górka on 17/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit
import FirebaseFirestore

class TabBarVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController)
    -> Bool {

           let index = viewControllers?.firstIndex(of: viewController)
           if index == 1 {

               let quoteSelectionVC = QuoteSelectionVC()
               let navController = UINavigationController(rootViewController: quoteSelectionVC)
            navController.modalPresentationStyle = .fullScreen
               present(navController, animated: true, completion: nil)

               return false
           }

           return true
       }

    fileprivate func setupViewControllers() {

        guard let homeImage = UIImage.init(systemName: "house"),
            let homeSelectedImage = UIImage.init(systemName: "house.fill"),
            let cameraImage = UIImage.init(systemName: "plus"),
            let profileImage = UIImage(systemName: "person"),
            let profileSelectedImage = UIImage(systemName: "person.fill")
            else { return }

        let homeViewController = templateNavController(image: homeImage,
                                                       selectedImage: homeSelectedImage,
                                                       rootViewController: HomeVC())

        let cameraViewController = templateNavController(image: cameraImage,
                                                         selectedImage: cameraImage)

        let profileViewController = templateNavController(image: profileImage,
                                                          selectedImage: profileSelectedImage,
                                                          rootViewController: ProfileVC())

        viewControllers = [homeViewController, cameraViewController, profileViewController]

        guard let items = tabBar.items else { return }

        for item in items {
            item.imageInsets = UIEdgeInsets(top: Constraints.topTabBarIconSpacing,
                                            left: 0,
                                            bottom: Constraints.bottomTabBarIconSpacing,
                                            right: 0)
        }
    }

    fileprivate func templateNavController(image: UIImage,
                                           selectedImage: UIImage,
                                           rootViewController: UIViewController = UIViewController())
        -> UINavigationController {
            let navController = UINavigationController(rootViewController: rootViewController)
            navController.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
            navController.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
            return navController
    }
}
