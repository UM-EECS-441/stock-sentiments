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
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
      
        // setup refreshControl here later
        let refreshControl = UIRefreshControl()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Stock Data...")
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.addTarget(self, action: #selector(handleRefresh(_: )), for: .valueChanged)

        sharedUser.requestAndUpdateUserWatchlist(autoReset: true, completion: {
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
        
        // Just update, no need to re-request
        self.tableView.reloadData()
    }

    @objc func handleRefresh(_ sender: Any) {
        // Manually resetting user's watchlist (race cond. fix)
        sharedUser.resetWatchlist()
        self.tableView.reloadData()
        sharedUser.requestAndUpdateUserWatchlist(autoReset: false, completion: {
            // Reload data from main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        self.refreshControl?.endRefreshing()
    }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return sharedUser.orderedWatchlistKeys.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        // click handler
        // set ticker equal to current ticker
        guard let ticker = sharedUser.watchlist[sharedUser.orderedWatchlistKeys[indexPath.row]] else {
            fatalError()
        }

        guard let sentimentVC = sentimentStoryboard.instantiateViewController(withIdentifier: "SentimentVC") as? SentimentVC else {
            fatalError("Failed to load SentimentVC")
        }
        sentimentVC.ticker = ticker
        sentimentVC.pVC = self

        self.present(sentimentVC, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistCell", for: indexPath) as? WatchlistCell else {
            fatalError("No reusable cell!")
        }

        // set ticker equal to current ticker
        guard let ticker = sharedUser.watchlist[sharedUser.orderedWatchlistKeys[indexPath.row]] else {
            fatalError()
        }

        // set color
        let sentimentLabel: SentimentLabel = getSentimentLabel(score: ticker.sentimentScore)
        cell.setColor(primary: sentimentLabel.color)

        // set text
        cell.tickerSymbol.text = ticker.symbol
        cell.tickerSymbol.sizeToFit()
        cell.tickerName.text = ticker.name
        cell.tickerName.sizeToFit()
        cell.sentimentScore.text = String(ticker.sentimentScore)
        cell.sentimentScore.sizeToFit()

        return cell
    }
}
