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

    @IBOutlet weak var sentimentDescription: UITextView!

    @IBAction func unsubscribeTapped(_ sender: Any) {
        let subscribeVC =  subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
        subscribeVC.watchlistItem = watchlistItem

        self.present(subscribeVC, animated: true, completion: nil)
    }
    @IBOutlet weak var sentimentUnsubscribe: UIButton!
    @IBOutlet weak var sentimentScore: UILabel!
    @IBOutlet weak var sentimentTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let watchlistItem = self.watchlistItem else{
            return
        }
        
        let sentimentLabel: SentimentLabel = getSentimentLabel(score: watchlistItem.sentimentScore)
        view.backgroundColor = sentimentLabel.color
        sentimentDescription.backgroundColor = sentimentLabel.color
        sentimentDescription.text = "People are saying " + sentimentLabel.rawValue + " things about " + watchlistItem.name
        
        sentimentTitle.text = watchlistItem.name + " (" + watchlistItem.symbol + ")"
        sentimentScore.text = String(watchlistItem.sentimentScore)

    }
}
