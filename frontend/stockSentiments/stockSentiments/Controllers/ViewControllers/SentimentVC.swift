//
//  SentimentVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let sentimentStoryboard: UIStoryboard = UIStoryboard(name: "Sentiment", bundle: nil)

class SentimentVC: UIViewController {
    
    var ticker: Ticker? = nil
    var selectSort:String? = nil
    var tickerSymbol: String? = nil
    
    var pVC: UITableViewController? = nil // pointer to parent view controller needed to replace view

    @IBOutlet weak var sentimentTitle: UILabel!
    @IBOutlet weak var sentimentScore: UILabel!
    @IBOutlet weak var sentimentDescription: UITextView!
    @IBOutlet weak var sentimentUnsubscribe: UIButton!
    
    // Create unsubscribe alert and bind actions to click options
    @IBAction func unsubscribeTapped(_ sender: Any) {

        guard let ticker = self.ticker else {
            fatalError("SentimentVC doesn't have Ticker in scope")
        }
        
        let unsubscribeAlert = UIAlertController(title: "Unsubscribe", message: "Are You Sure you want to unsubscribe from " + ticker.symbol + "?", preferredStyle: UIAlertController.Style.alert)

        unsubscribeAlert.addAction(UIAlertAction(title: "Unsubscribe", style: .default, handler: { (action) -> Void in
            requestUnSubscribe(to: ticker.symbol) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: { [self] in
                            let subscribeVC =  subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC

                            user.requestAndUpdateUserWatchlist(autoReset: true, sortType: selectSort!, completion: {
                                subscribeVC.tickerSymbol = ticker.symbol
                                subscribeVC.tickerName = ticker.name
                                // set destination's parent to self's parent and present modally from parent
                                guard let pVC = self.pVC else {
                                    fatalError("Parent view controller not set")
                                }
                                subscribeVC.pVC = pVC
                                DispatchQueue.main.async {
                                    self.pVC?.present(subscribeVC, animated: true, completion: self.refreshWatchlistTableViewIfIsParent)
                                }
                            })
                        })
                    }
                } else {
                    print("already subbed")
                }
            }
        }))

        unsubscribeAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            unsubscribeAlert.dismiss(animated: true, completion: nil)
        }))

        present(unsubscribeAlert, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let ticker = self.ticker else {
            fatalError("SentimentVC doesn't have Ticker in scope")
        }

        // set color
        let sentimentLabel: SentimentLabel = getSentimentLabel(score: ticker.sentimentScore)
        self.setColor(primary: sentimentLabel.color)
        
        // set text
        sentimentTitle.text = ticker.name + " (" + ticker.symbol + ")"
        sentimentScore.text = String(ticker.sentimentScore)
        sentimentDescription.text = "People are saying " + sentimentLabel.rawValue + " things about " + ticker.name
    }
    
    // reloads table view data using the pVC pointer
    func refreshWatchlistTableViewIfIsParent() {
        if let pVC = self.pVC as? WatchlistVC {
            DispatchQueue.main.async {
                pVC.tableView.reloadData()
            }
        }
    }
    
    func setColor(primary primaryColor: UIColor) {
//        sentimentTitle.textColor = primaryColor
        sentimentScore.textColor = primaryColor
//        sentimentDescription.textColor = primaryColor
        sentimentUnsubscribe.backgroundColor = primaryColor
    }
}
