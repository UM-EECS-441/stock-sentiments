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
    
    var searchActive : Bool = false
    

    //TODO: include filter results function

    var topSearchResults = [SearchResult]() // array of search results
    var filteredResults: [SearchResult] = []// array of filtered results

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // setup delegates
        searchItem.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        requestSupportedTickers(completionHandler: { (supportedTickers) -> Void in
            self.supportedTickers = supportedTickers
            
            // TODO: change this to select only the "top tickers"
            for (symbol, _) in self.supportedTickers!.symbolToName {
                self.topSearchResults.append(SearchResult(tickerSymbol: symbol))
            }
            
            // Reload data from main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
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
        // TODO: we need to filter an appended list of (all symbols) + (all names)
        let keys: [SearchResult] = Array(supportedTickers!.symbolToName.keys).map { (string) -> SearchResult in
            SearchResult(tickerSymbol: string)
        }
        filteredResults = keys.filter({ (searchResult) -> Bool in
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
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
            fatalError("No reusable cell!")
        }

        let searchResult = searchActive ? filteredResults[indexPath.row] : topSearchResults[indexPath.row]
        
        cell.tickerName.text = searchResult.symbol
        cell.tickerName.sizeToFit()
        cell.viewStock.isHidden = false
        cell.renderSearch = { () in
            let subscribeVC = subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
            subscribeVC.tickerSymbol = searchResult.symbol
            subscribeVC.pVC = self

            self.present(subscribeVC, animated: true, completion: nil)
        }

        return cell
   }
    
}
