//
//  GetWatchlist.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/25/20.
//

import Foundation


/* function takes in a completion handler to call after completing the request. This is a form of delegation
 to pass data back to the caller.
 */
func requestUserWatchlist(completionHandler: @escaping ([WatchlistResponse]) -> Void) -> Void {
    let queryParameters = "?uid=X01X23Y4XYXY"
    
    let requestUrl = baseUrl + "get_watchlist_scores/" + queryParameters
    let request = URLRequest(url: URL(string: requestUrl)!)
    
    // TODO: how to do query parameter
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("something went wrong in fetching get_tickers/ request")
            return
        }
        
        // data is not nil ** TODO: make sure this is true
        var decodedResponse: GetWatchlistResponse?
        do {
            decodedResponse = try JSONDecoder().decode(GetWatchlistResponse.self, from: data!)
        } catch {
            print("error in decoding \(error.localizedDescription)")
            return
        }
        
        // pass watchlist back to WatchlistVC a
        completionHandler(decodedResponse!.data)
//        completionHandler(Watchlist(response: decodedResponse!.data))
    }
    task.resume()
}

// MARK: Codable Helper Structs

// Stores response of /get_watchlist_scores
struct GetWatchlistResponse : Codable {
    var uid: String
    var data: [WatchlistResponse]
}

// stores watchlist information for a ticker
struct WatchlistResponse : Codable {
    var symbol: String
    var name: String
    var score: Double
    var timestamp: String
}
