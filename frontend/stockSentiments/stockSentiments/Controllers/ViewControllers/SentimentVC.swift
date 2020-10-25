//
//  SentimentVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let sentimentStoryboard: UIStoryboard = UIStoryboard(name: "Sentiment", bundle: nil)
class SentimentVC: UIViewController {
    var watchlistItem: WatchlistItem? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (self.watchlistItem != nil){
            // set button variables to text from watchlist and fetch stock sentiment details
        }
    }

}
