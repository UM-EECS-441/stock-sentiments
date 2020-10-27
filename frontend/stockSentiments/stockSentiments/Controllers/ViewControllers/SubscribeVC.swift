//
//  SubscribeVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let subscribeStoryboard: UIStoryboard = UIStoryboard(name: "Subscribe", bundle: nil)

class SubscribeVC: UIViewController {
    
    var search: SearchResult? = nil
    var ticker: Ticker? = nil

    @IBOutlet weak var stockTitle: UILabel!
    @IBOutlet weak var messagetextView: UITextView!
    @IBOutlet weak var subscribeButton: UIButton!
    
    @IBAction func subscribeTapped(_ sender: Any) {
        /* TODO:
            1. Check if User is a subsciption member, if they're not check if user has reached subscription limit, if they have do not allow to subscribe to stock ticker
            2. Change this to a modal replacement to SentimentVC
         */
        if (subscribeButton.currentTitle == "Subscribe") {
            subscribeButton.setTitle("Unsubscribe", for: .normal)
        } else {
            subscribeButton.setTitle("Subscribe", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        // TODO: set stock title to title from stock click or through a fetch api
        if let search = self.search {
            stockTitle.text = search.symbol
        }
        else if let ticker = self.ticker {
            stockTitle.text = ticker.name
        }

        // TODO: retrieve stock description from database and update stock description
        messagetextView.text = "This is the default stock description"
    }

}
