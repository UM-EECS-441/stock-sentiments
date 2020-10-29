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
        
        /* TODO: get request to subscribe to ticker,
         if 200: update the user's watchlist
         if 500: say failed
         */
        requestSubscribe(to: tickerSymbol!) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        let sentimentVC = sentimentStoryboard.instantiateViewController(withIdentifier: "SentimentVC") as! SentimentVC
         
                        // refresh watchlist
                        user.requestAndUpdateUserWatchlist(completion: {
                            sentimentVC.ticker = user.watchlist[self.tickerSymbol!]
                            // set destination's parent to self's parent and present modally from parent
                            guard let pVC = self.pVC else {
                                fatalError("Parent view controller not set")
                            }
                            sentimentVC.pVC = pVC
                            DispatchQueue.main.async {
                                pVC.present(sentimentVC, animated: true, completion: nil)
                            }
                        }) 
                    })
                }
            } else {
                print("already subbed")
            }
        }
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        print("View has disappeared")

        user.requestAndUpdateUserWatchlist(completion: {
            // Reload data from main thread
            DispatchQueue.main.async {

                print("refresh")
            }

        })
    }

}
