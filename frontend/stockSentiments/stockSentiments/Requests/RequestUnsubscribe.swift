//
//  unsubscribe.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/26/20.
//

import Foundation

/* function takes in a completion handler to call after completing the request. This is a form of delegation
 to pass data back to the caller.
 */
func requestUnSubscribe(to tickerSymbol: String, success: @escaping (Bool) -> Void) {
    //http://161.35.6.60/user/unsubscribe/?userID=2&ticker=FB
    let queryParameters = "?userID=" + sharedUser.userId + "&ticker=" + tickerSymbol

    let requestUrl = baseUrl + "user/unsubscribe/" + queryParameters
    let request = URLRequest(url: URL(string: requestUrl)!)

    // TODO: how to do query parameter

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("something went wrong in fetching get_tickers/ request")
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            if httpResponse.statusCode == 500 {
                print("User is already unsubscribed to " + tickerSymbol)
                // notify caller of failure
                success(false)
            } else if httpResponse.statusCode == 200 {
                print("User successfully unsubscribed to " + tickerSymbol)
                // notify caller of success
                success(true)
            } else {
                fatalError("Why is it here")
            }
        }
    }
    task.resume()
}

