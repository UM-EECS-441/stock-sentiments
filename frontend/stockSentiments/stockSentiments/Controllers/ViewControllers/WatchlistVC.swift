//
//  WatchlistVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let watchlistStoryboard: UIStoryboard = UIStoryboard(name: "Watchlist", bundle: nil)

class WatchlistVC: UITableViewController, UITabBarDelegate {
    
    var watchlistInstance: Watchlist? = nil
    
//    var watchlist = [WatchlistItem]() // array of watchlist

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        // setup refreshControl here later
        refreshControl?.addTarget(self, action: #selector(WatchlistVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        // request watchlist and store in watchlist member variable
        requestUserWatchlist(completionHandler: { (watchlist) -> Void in
            self.watchlistInstance = watchlist
            
            // Reload data from main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set nav title and don't allow back functionality
        self.tabBarController?.navigationItem.title = "Watchlist"
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
//            getWatchs()
        }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return watchlistInstance?.watchlist.count ?? 0
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

        let watchlistItem = watchlistInstance?
            .watchlist[indexPath.row]
        cell.stockName.text = watchlistItem?.symbol
        cell.stockName.sizeToFit()
        cell.sentimentScore.text = String(watchlistItem!.sentimentScore)
        cell.sentimentScore.sizeToFit()

        cell.sentimentButton.isHidden = false
        cell.renderChatt = { () in
            let sentimentVC = sentimentStoryboard.instantiateViewController(withIdentifier: "SentimentVC") as! SentimentVC
            sentimentVC.watchlistItem = self.watchlistInstance?.watchlist[indexPath.row]
            
            self.present(sentimentVC, animated: true, completion: nil)
        }

       return cell
   }
}
