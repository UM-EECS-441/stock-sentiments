//
//  Requests.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/25/20.
//

import Foundation


/* function takes in a completion handler to call after completing the request. This is a form of delegation
 to pass data back to the caller.
 */
func requestSupportedTickers(completionHandler: @escaping (SupportedTickers) -> Void) {
    
    let requestUrl = baseUrl + "get_tickers/"
    let request = URLRequest(url: URL(string: requestUrl)!)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("something went wrong in fetching get_tickers/ request")
            return
        }
        
        // data is not nil ** TODO: make sure this is true
        var decodedResponse: GetSupportedTickersResponse?
        do {
            decodedResponse = try JSONDecoder().decode(GetSupportedTickersResponse.self, from: data!)
        } catch {
//            print("something went wrong in decoding get_tickers/ response")
            print("error in decoding \(error.localizedDescription)")
            return
        }
        
        print("worked")
        // request is complete, call completion handler
        completionHandler(SupportedTickers(response: decodedResponse!.data))
    }
    task.resume()
}

// MARK: Codable Helper Structs

// Stores response of /get_tickers
struct GetSupportedTickersResponse : Codable {
//    let status: String
    var data: [TickerResponse]
}

// stores base information for a ticker
struct TickerResponse : Codable {
    var symbol: String
    var name: String
    var count: Int
}

