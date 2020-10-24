//
//  WatchlistVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let watchlistStoryboard: UIStoryboard = UIStoryboard(name: "Watchlist", bundle: nil)

class WatchlistVC: UITableViewController, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    var viewController1: UIViewController?
    var viewController2: UIViewController?
    var viewController3: UIViewController?

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            print(item)
           switch item.tag {

           case 1:
            print("search")
               if viewController1 == nil {

                viewController1 = searchStoryboard.instantiateInitialViewController() as! SearchVC
                print("search")
           }
               self.view.insertSubview(viewController1!.view!, belowSubview: self.tabBar)
               break


           case 2:
            print("watchlist")
               if viewController2 == nil {

                // do nothing
           }
               break

           case 3:
            print("settings")
            if viewController3 == nil {

                viewController2 = settingsStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            }

            self.view.insertSubview(viewController2!.view!, belowSubview: self.tabBar)
            break

           default:
               break

           }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tabBar.delegate = self

    }
    
}
