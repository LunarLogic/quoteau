//
//  TabBarViewController.swift
//  Quotes
//
//  Created by Wiktor Górka on 16/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
    }
    
    
    fileprivate func setupViewControllers() {
        
        let homeViewController = templateNavController(unselectedImage: UIImage.init(systemName: "house")!, selectedImage: UIImage.init(systemName: "house.fill")!)
        
        let cameraViewController = templateNavController(unselectedImage: UIImage.init(systemName: "plus")!, selectedImage: UIImage.init(systemName: "plus")!)
        
        let profileViewController = templateNavController(unselectedImage: UIImage(systemName: "person")!, selectedImage: UIImage(systemName: "person.fill")!)
        
        viewControllers = [homeViewController, cameraViewController, profileViewController]
        
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
        
    }
    
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        return navController
    }
    

}
