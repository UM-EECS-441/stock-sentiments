//
//  subscribe.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/26/20.
//

import Foundation


/* function takes in a completion handler to call after completing the request. This is a form of delegation
 to pass data back to the caller.
 */
func requestSubscribe(to tickerSymbol: String, success: @escaping (Bool) -> Void) -> Void {
    //http://161.35.6.60/user/subscribe/?uid=2&ticker=FB
    let queryParameters = "?userID=" + sharedUser.userId + "&ticker=" + tickerSymbol
    
    let requestUrl = baseUrl + "user/subscribe/" + queryParameters
    print(requestUrl)
    let request = URLRequest(url: URL(string: requestUrl)!)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("something went wrong in fetching get_tickers/ request")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            if httpResponse.statusCode == 500 {
                print("User is already subscribed to " + tickerSymbol)
                // notify caller of failure
                success(false)
            } else if httpResponse.statusCode == 200 {
                print("User successfully subscribed to " + tickerSymbol)
                // notify caller of success
                success(true)
            } else {
                fatalError("Why is it here")
            }
        }
    }
    task.resume()
}

