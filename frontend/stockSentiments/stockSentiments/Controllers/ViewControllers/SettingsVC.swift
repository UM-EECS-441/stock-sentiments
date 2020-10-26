//
//  SettingsVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let settingsStoryboard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set nav title and don't allow back functionality from the watchlist to signin page
        self.tabBarController?.navigationItem.title = "Settings"
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
    }

}
