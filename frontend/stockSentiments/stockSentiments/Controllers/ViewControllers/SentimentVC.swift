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

    @IBOutlet weak var sentimentTitle: UILabel!
    @IBOutlet weak var sentimentScore: UILabel!
    @IBOutlet weak var sentimentDescription: UITextView!
    @IBOutlet weak var sentimentUnsubscribe: UIButton!
    
    @IBAction func unsubscribeTapped(_ sender: Any) {
        let subscribeVC =  subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
        subscribeVC.ticker = ticker

        self.present(subscribeVC, animated: true, completion: nil)
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

    }
}
