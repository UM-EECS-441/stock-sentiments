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
    var tickerSymbol: String? = nil
    
    var pVC: UITableViewController? = nil // pointer to parent view controller needed to replace view

    @IBOutlet weak var sentimentTitle: UILabel!
    @IBOutlet weak var sentimentScore: UILabel!
    @IBOutlet weak var sentimentDescription: UITextView!
    @IBOutlet weak var sentimentUnsubscribe: UIButton!
    
    @IBAction func unsubscribeTapped(_ sender: Any) {
        // unsubscribe api called
        /* TODO: get request to unsubscribe to ticker,
         if 200: update the user's watchlist
         if 500: say failed
         */
        requestUnSubscribe(to: ticker!.symbol) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        let subscribeVC =  subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
                        
                        user.requestAndUpdateUserWatchlist(completion: {
                            subscribeVC.tickerSymbol = self.ticker?.symbol
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

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let ticker = self.ticker else {
            return
        }

        
        // set color
        let sentimentLabel: SentimentLabel = getSentimentLabel(score: ticker.sentimentScore)
        view.backgroundColor = sentimentLabel.color
        sentimentDescription.backgroundColor = sentimentLabel.color
        
        // set text
        sentimentTitle.text = ticker.name + " (" + ticker.symbol + ")"
        sentimentScore.text = String(ticker.sentimentScore)
        sentimentDescription.text = "People are saying " + sentimentLabel.rawValue + " things about " + ticker.name
        
        
        // TODO: replace this with a better system
        sentimentTitle.textColor = .white
        sentimentScore.textColor = .white
        sentimentDescription.textColor = .white

    }
    
    
    // reloads table view data using the pVC pointer
    func refreshWatchlistTableViewIfIsParent() {
        if let pVC = self.pVC as? WatchlistVC {
            DispatchQueue.main.async {
                pVC.tableView.reloadData()
            }
        }
    }
}
