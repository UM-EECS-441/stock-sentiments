//
//  ViewController.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/12/20.
//

import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func guestTapped() {
        print("tapped")
        
        guard let watchlistVC = watchlistStoryboard.instantiateViewController(identifier: "WatchlistVC") as? WatchlistVC else {
            print("failed to load watchlistVC")
            return
        }
        present(watchlistVC, animated: true)
    }
}

