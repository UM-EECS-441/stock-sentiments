//
//  RequestToggleNotifications.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 12/1/20.
//

import Foundation


func requestToggleNotifications(on turnOn: Bool, success: @escaping (Bool) -> Void) {
    //http://161.35.6.60/toggle_notifications/?userID=2&notifications={turnOn}
//    let queryParameters = "?userID=" + sharedUser.userId + "&notifications=" + String(turnOn)
    
    let requestUrl = baseUrl + "toggle_notifications/"// + queryParameters
    print(requestUrl)
        
    var request = URLRequest(url: URL(string: requestUrl)!)
    request.httpMethod = "POST"
    
    let json: [String: Any] = ["userID": sharedUser.userId,
                               "notifications" : String(turnOn)]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)
    request.httpBody = jsonData
        
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("something went wrong in fetching toggle_notifications/ request")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            if httpResponse.statusCode == 200 {
                print("Successfully turned", turnOn, "email notifications.")
                // notify caller of success
                success(true)
            } else {
                print("Failed on toggling notifications with status code", httpResponse.statusCode)
                success(false)
            }
        }
    }
    task.resume()
}


