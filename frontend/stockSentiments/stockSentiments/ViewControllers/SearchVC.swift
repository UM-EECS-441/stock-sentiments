//
//  SearchVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let searchStoryboard: UIStoryboard = UIStoryboard(name: "Search", bundle: nil)

class SearchVC: UITableViewController {

    //TODO: include filter results function

    var searchs = [search]() // array of search cells

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the  view.

        //getSearchs()
    }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return searchs.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           // populate a single cell
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? searchCell else {
               fatalError("No reusable cell!")
           }

           let search = searchs[indexPath.row]
        cell.tickerName.text = search.tickerName
        cell.tickerName.sizeToFit()




            cell.viewStock.isHidden = false
            cell.renderSearch = {
            () in
            let subscribeVC = subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
                subscribeVC.search = self.searchs[indexPath.row]

            self.present(subscribeVC, animated: true, completion: nil)
            }

           return cell
       }
    func getSearchs(){
        // retrieves all tickers
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
                self.searchs = [search]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let searchReceived = json["search"] as? [[String]] ?? []
                for searchEntry in searchReceived {
                    let searcher = search(tickerName: searchEntry[0])
                    self.searchs += [searcher]
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

    }
    
}
