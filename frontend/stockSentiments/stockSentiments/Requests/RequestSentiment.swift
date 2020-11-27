//
//  RequestSentiment.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 11/27/20.
//

import Foundation

/* function takes in a completion handler to call after completing the request. This is a form of delegation
 to pass data back to the caller.
 */

// stores ticker name and sentiment data for ticker symbol
struct TickerDataResponse: Codable{
    var ticker: String
    var data: [Data]
}

// ticker symbol dataset
struct Data: Codable{
    var ticker: String
    var sentiment: Double
    var time: String
    var price: Double
}

func requestSentiment(to tickerSymbol: String, completionHandler: @escaping ([Data]) -> Void) -> Void {
    //http://161.35.6.60/get_sentiment_score/?ticker=AAPL
    let queryParameters = "?ticker=" + tickerSymbol

    let requestUrl = baseUrl + "get_sentiment_score" + queryParameters
    print(requestUrl)
    let request = URLRequest(url: URL(string: requestUrl)!)

    // TODO: how to do query parameter

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("something went wrong in fetching get_tickers/ request")
            return
        }
        // data is not nil ** TODO: make sure this is true
        var decodedResponse: TickerDataResponse?
        do {
            decodedResponse = try JSONDecoder().decode(TickerDataResponse.self, from: data!)
        } catch let jsonError as NSError {
//            print(error)
            print("JSON decode failed: \(jsonError.localizedDescription)")
            return
        }

        // pass sentiment back to sentimentVC
        completionHandler(decodedResponse!.data)
//        completionHandler(Watchlist(response: decodedResponse!.data))
    }
    task.resume()
}
