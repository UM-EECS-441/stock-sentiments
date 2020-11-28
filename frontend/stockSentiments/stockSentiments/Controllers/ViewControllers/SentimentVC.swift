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
    var selectSort: String? = ""
    var tickerSymbol: String? = nil

    var sentimentResults: [Data]? = nil

    // three axis points
    var time_axis: [String]? = nil
    var sentiment_axis: [Double]? = nil
    var stock_axis: [Double]? = nil
    
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

<<<<<<< HEAD
                            sharedUser.requestAndUpdateUserWatchlist(autoReset: true, sortType: selectSort!, completion: {
=======
                            sharedUser.requestAndUpdateUserWatchlist(autoReset: true, completion: {
>>>>>>> 7cf4713f57067ff6f2b612bc57cf9ac5dbd874ce
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

        requestSentiment(to: ticker.symbol, completionHandler: {
            (sentiments) -> Void in
            self.sentimentResults = sentiments

            for sentiment in self.sentimentResults!.reversed(){
                self.time_axis?.append(sentiment.time)
                self.sentiment_axis?.append(sentiment.sentiment)
                self.stock_axis?.append(sentiment.price)
                print("timestamp: " + sentiment.time + ", y1(Sentiment score): " + String(sentiment.sentiment) + ", y2(Stock Price): " + String(sentiment.price))
                
            }
        })
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
