//
//  TabBarController.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/27/20.
//

import UIKit

class TabBarController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start on watchlist
        self.selectedIndex = 1
        
        // TODO: make a color class
        tabBar.tintColor = UIColor(red: CGFloat(47/255.0), green: CGFloat(196/255.0), blue: CGFloat(52/255.0), alpha: CGFloat(1.0))
        tabBar.unselectedItemTintColor = .gray
    }
}
