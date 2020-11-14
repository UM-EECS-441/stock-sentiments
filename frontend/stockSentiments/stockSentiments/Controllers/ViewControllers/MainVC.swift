//
//  ViewController.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/12/20.
//

import UIKit

class MainVC: UIViewController {
    
    @IBOutlet weak var signinButton: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        signinButton.backgroundColor = .systemGray
        signinButton.tintColor = .systemBackground
    }
    
    @IBAction func signinButtonTapped(_ sender: Any) {
        guard let signinVC = signinStoryboard.instantiateViewController(identifier: "SigninVC") as? SigninVC else {
            print("failed to load signinVC")
            return
        }
        
        present(signinVC, animated: true, completion: nil)
    }
    
    @IBAction func guestTapped() {
        print("tapped")
        
//        guard let watchlistVC = watchlistStoryboard.instantiateViewController(identifier: "WatchlistVC") as? WatchlistVC else {
//            print("failed to load watchlistVC")
//            return
//        }

//        self.navigationController?.pushViewController(watchlistVC, animated: true)
    }
    
    
}

