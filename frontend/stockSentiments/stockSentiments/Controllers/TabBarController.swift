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
    }
}
