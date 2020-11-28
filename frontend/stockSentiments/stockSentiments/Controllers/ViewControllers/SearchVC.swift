//
//  SearchVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let searchStoryboard: UIStoryboard = UIStoryboard(name: "Search", bundle: nil)

class SearchVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchItem: UISearchBar!
    
    // nil until SearchVC is instantiated for the first time
    var supportedTickers: SupportedTickers? = nil
    
    var allPossibleResults = [SearchResult]() // array of all possible search results
    var topSearchResults = [SearchResult]()   // array of search results
    var filteredResults = [SearchResult]()    // array of filtered results
    
    var searchActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // setup delegates
        searchItem.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        requestSupportedTickers(completionHandler: { (supportedTickers) -> Void in
            self.supportedTickers = supportedTickers
            
            self.allPossibleResults = Array(self.supportedTickers!.symbolToName.keys).map { (symbol) -> SearchResult in
                SearchResult(tickerSymbol: symbol, tickerName: supportedTickers.symbolToName[symbol]!, count: supportedTickers.symbolToCount[symbol]!)
                
            }
            
            
            
            // TODO: display all or just 10?
            self.topSearchResults = self.allPossibleResults.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.count > rhs.count // TODO: check if correct
            })
            
            // Reload data from main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set nav title and don't allow back functionality
        self.tabBarController?.navigationItem.title = "Search"
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
    }

    // MARK:- Search Bar handlers
    func searchBarTextDidBeginEditing(searchItem: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(searchItem: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(searchItem: UISearchBar) {
        searchActive = false;
    }

    func searchBarSearchButtonClicked(searchItem: UISearchBar) {
        searchActive = false;
    }

    func searchBar(_ searchItem: UISearchBar, textDidChange searchText: String) {
        
        filteredResults = self.allPossibleResults.filter({ (searchResult) -> Bool in
            let symbol: NSString = searchResult.symbol as NSString
            let name: NSString = supportedTickers!.symbolToName[searchResult.symbol]! as NSString
            let rangeSymbol = symbol.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let rangeName = name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return rangeSymbol.location != NSNotFound || rangeName.location != NSNotFound
        })
        
        if (filteredResults.count == 0) {
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section

        return searchActive ? filteredResults.count : topSearchResults.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        let searchResult = searchActive ? filteredResults[indexPath.row] : topSearchResults[indexPath.row]
        
        if let ticker = sharedUser.watchlist[searchResult.symbol] {
            guard let sentimentVC = sentimentStoryboard.instantiateViewController(withIdentifier: "SentimentVC") as? SentimentVC else {
                fatalError("failed to load SentimentVC from search")
            }
            sentimentVC.ticker = ticker
            sentimentVC.pVC = self
            
            self.present(sentimentVC, animated: true, completion: nil)
        } else {
            guard let subscribeVC = subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as? SubscribeVC else {
                fatalError("failed to load SubscribeVC from search")
            }
            subscribeVC.tickerSymbol = searchResult.symbol // TODO: encapsulate these
            subscribeVC.tickerName = searchResult.name
            subscribeVC.pVC = self

            self.present(subscribeVC, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
            fatalError("No reusable cell!")
        }

        let searchResult = searchActive ? filteredResults[indexPath.row] : topSearchResults[indexPath.row]
        
        cell.tickerSymbol.text = searchResult.symbol
        cell.tickerSymbol.sizeToFit()
        cell.tickerName.text = searchResult.name
        cell.tickerName.sizeToFit()
        cell.tickerCount.text = String(searchResult.count) + " subs."
        cell.tickerName.sizeToFit()
//        cell.viewStock.isHidden = false
        
        return cell
   }
    
}
