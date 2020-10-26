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
        tabBar.delegate = self      
              
        // Set nav title and don't allow back functionality from the watchlist to signin page
        self.navigationItem.title = "Watchlist"
        self.navigationItem.setHidesBackButton(true, animated: false)
      
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
    
    
    @IBOutlet weak var tabBar: UITabBar!
    var viewController1: UIViewController?
    var viewController2: UIViewController?
    var viewController3: UIViewController?
    // TODO: put this code somewhere else
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            print(item)
           switch item.tag {

           case 1:
            print("search")
               if viewController1 == nil {

                viewController1 = searchStoryboard.instantiateInitialViewController() as! SearchVC
                print("search")
           }
               self.view.insertSubview(viewController1!.view!, belowSubview: self.tabBar)
               break


           case 2:
            print("watchlist")
               if viewController2 == nil {
                
                viewController2 = watchlistStoryboard.instantiateInitialViewController() as! WatchlistVC
                print("watchlist")
           }
               self.view.insertSubview(viewController2!.view!, belowSubview: self.tabBar)
               break

           case 3:
            print("settings")
            if viewController3 == nil {

                viewController2 = settingsStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            }

            self.view.insertSubview(viewController2!.view!, belowSubview: self.tabBar)
            break

           default:
               break

           }

    }
    /*
    func getWatchs(){
        // retrieves tickers
        let requestURL = ""
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                DispatchQueue.main.async {
                  self.refreshControl?.endRefreshing()
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                DispatchQueue.main.async {
                  self.refreshControl?.endRefreshing()
                }
                return
            }

            do {
                self.watchs = [WatchlistItem]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let watchsReceived = json["watchs"] as? [[String]] ?? []
                for watchEntry in watchsReceived {
                    let watcher = WatchlistItem(tickerSymbol: watchEntry[0], sentimentScore: watchEntry[1])
                    self.watchs += [watcher]
                }
                DispatchQueue.main.async {
                  self.tableView.estimatedRowHeight = 140
                  self.tableView.rowHeight = UITableView.automaticDimension
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()

    } */
    
}
