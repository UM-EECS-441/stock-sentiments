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
    var searchActive : Bool = false
    // nil until SearchVC is instantiated for the first time
    var supportedTickers: SupportedTickers? = nil

    //TODO: include filter results function

    var searchResults = [SearchResult]() // array of search results
    var filteredResults:[SearchResult] = []// array of filtered results

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the  view.
        
        // completion handler has access to supportedTickers passed by delegator
        // https://stackoverflow.com/questions/30401439/how-could-i-create-a-function-with-a-completion-handler-in-swift

        // setup delegates
        searchItem.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        requestSupportedTickers(completionHandler: { (supportedTickers) -> Void in
            self.supportedTickers = supportedTickers
            
            for (symbol, _) in self.supportedTickers!.symbolToName {
                self.searchResults.append(SearchResult(tickerSymbol: symbol))
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
        filteredResults = searchResults.filter({ (text) -> Bool in
        let tmp:NSString = text.symbol as NSString
        let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
        return range.location != NSNotFound
        })
        if(filteredResults.count == 0){
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
        if(searchActive){
            return filteredResults.count
        }
        print(searchResults.count)
        return searchResults.count
//        return 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        print("hi")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
            fatalError("No reusable cell!")
        }

//        let search = searchs[indexPath.row]
//        cell.tickerName.text = search.tickerName
//        cell.tickerName.sizeToFit()
        if(searchActive){
            let filterResult = filteredResults[indexPath.row]
            cell.tickerName.text = filterResult.symbol
            cell.tickerName.sizeToFit()
            cell.viewStock.isHidden = false
            cell.renderSearch = { () in
                let subscribeVC = subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
                subscribeVC.search = self.filteredResults[indexPath.row]

                self.present(subscribeVC, animated: true, completion: nil)
            }
        }
        else{
            let searchResult = searchResults[indexPath.row]
            cell.tickerName.text = searchResult.symbol
            cell.tickerName.sizeToFit()
            cell.viewStock.isHidden = false
            cell.renderSearch = { () in
                let subscribeVC = subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
                subscribeVC.search = self.searchResults[indexPath.row]

                self.present(subscribeVC, animated: true, completion: nil)
            }
        }


        return cell
   }
    
}
