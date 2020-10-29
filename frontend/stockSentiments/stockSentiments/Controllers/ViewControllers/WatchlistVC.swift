//
//  WatchlistVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let watchlistStoryboard: UIStoryboard = UIStoryboard(name: "Watchlist", bundle: nil)

class WatchlistVC: UITableViewController, UITabBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        // setup refreshControl here later
        refreshControl?.addTarget(self, action: #selector(WatchlistVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        user.requestAndUpdateUserWatchlist(completion: {
            // Reload data from main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("View will appear called")
        
        // Set nav title and don't allow back functionality
        self.tabBarController?.navigationItem.title = "Watchlist"
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        
        user.requestAndUpdateUserWatchlist(completion: {
            // Reload data from main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // TODO: request and update watchlist
        print("refresh called")
    }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
//        return watchlistInstance?.watchlist.count ?? 0
        return user.watchlist.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistCell", for: indexPath) as? WatchlistCell else {
            fatalError("No reusable cell!")
        }
        
        // set ticker equal to current ticker
        guard let ticker = user.watchlist[user.orderedWatchlistKeys[indexPath.row]] else {
            fatalError()
        }
        
        // set color
        let sentimentLabel: SentimentLabel = getSentimentLabel(score: ticker.sentimentScore)
        cell.backgroundColor = sentimentLabel.color
        
        // set text
        cell.stockName.text = ticker.symbol
        cell.stockName.sizeToFit()
        cell.sentimentScore.text = String(ticker.sentimentScore)
        cell.sentimentScore.sizeToFit()

        
        cell.sentimentButton.isHidden = false
        
        // click handler
        cell.renderChatt = { () in
            let sentimentVC = sentimentStoryboard.instantiateViewController(withIdentifier: "SentimentVC") as! SentimentVC
            sentimentVC.ticker = ticker
            sentimentVC.pVC = self
            
            self.present(sentimentVC, animated: true, completion: nil)
        }

       return cell
   }
}
