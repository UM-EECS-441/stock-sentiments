//
//  SubscribeVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let subscribeStoryboard: UIStoryboard = UIStoryboard(name: "Subscribe", bundle: nil)

class SubscribeVC: UIViewController {
    
    var tickerSymbol: String? = nil

    var pVC: UIViewController? = nil // pointer to parent view controller needed to replace view

    @IBOutlet weak var stockTitle: UILabel!
    @IBOutlet weak var messagetextView: UITextView!
    @IBOutlet weak var subscribeButton: UIButton!
    
    @IBAction func subscribeTapped(_ sender: Any) {
        /* TODO:
            1. Check if User is a subsciption member, if they're not check if user has reached subscription limit, if they have do not allow to subscribe to stock ticker
            2. Change this to a modal replacement to SentimentVC
         */
        dismiss(animated: true, completion: {
            let sentimentVC =  sentimentStoryboard.instantiateViewController(withIdentifier: "SentimentVC") as! SentimentVC
            // TODO: remove later (this is for testing, we need to actually pass in the ticker object) (the way it is now won't work in practice bc user won't have self.tickersymbol in their watchlist in this flow)
            sentimentVC.ticker = user.watchlist[self.tickerSymbol!]
            
            // set destination's parent to self's parent and present modally from parent
            guard let pVC = self.pVC else {
                fatalError("Parent view controller not set")
            }
            sentimentVC.pVC = pVC
            pVC.present(sentimentVC, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        // TODO: set stock title to title from stock click or through a fetch api
        if let tickerSymbol = self.tickerSymbol {
            stockTitle.text = tickerSymbol
        }
        
        // TODO: retrieve stock description from database and update stock description
        messagetextView.text = "This is the default stock description"
    }

}
