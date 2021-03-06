//
//  TabBarController.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/27/20.
//

import UIKit

let tabBarStoryboard: UIStoryboard = UIStoryboard(name: "TabBar", bundle: nil)

class TabBarController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start on watchlist
        self.selectedIndex = 1
        
        // TODO: make a color class
        tabBar.tintColor = customColorScheme.green
        tabBar.unselectedItemTintColor = .gray
    }
}
