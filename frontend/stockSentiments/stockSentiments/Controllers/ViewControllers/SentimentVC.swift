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
        sentimentTitle.text = watchlistItem.name + " (" + watchlistItem.symbol + ")"
        sentimentScore.text = String(watchlistItem.sentimentScore)
        if(watchlistItem.sentimentScore >= 0.33){
            //green
            view.backgroundColor = .green
            sentimentDescription.text = "People are saying good things about " + watchlistItem.name
            sentimentDescription.backgroundColor = .green

        }
        else if(watchlistItem.sentimentScore < -0.33 ){
            //red
            view.backgroundColor = .red
            sentimentDescription.text = "People are saying bad things about " + watchlistItem.name
            sentimentDescription.backgroundColor = .red
        }
        else{
            //amber
            view.backgroundColor = .orange
            sentimentDescription.text = "People are saying neutral things about " + watchlistItem.name
            sentimentDescription.backgroundColor = .orange

        }




    }
}
