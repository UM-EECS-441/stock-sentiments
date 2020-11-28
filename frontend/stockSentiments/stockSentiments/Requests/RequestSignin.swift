//
//  RequestSignin.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 11/14/20.
//

import Foundation


func requestSignin(_ idToken: String, success: @escaping (Bool) -> Void) {
    
    /**/
    print(sharedUser.userId)
    if sharedUser.userId == "" {
        // obtain chatterID from backend, replace the following line
        let json: [String: Any] = ["clientID": signinClientID,
                                   "idToken" : idToken]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Replace YOUR_SERVER_IP with the IP address of your droplet
        var request = URLRequest(url:
            URL(string: baseUrl + "sign_in/")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task =  URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                
                sharedUser.userId = ""
                success(false)
                
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                
                sharedUser.userId = ""
                success(false)
                
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!)
                    as? [String:Any] {
            
                    sharedUser.userId = json["userID"] as? String ?? ""
                    print("stored userId:", sharedUser.userId)
                    success(true)
                }
            } catch let err {
                sharedUser.userId = ""
                print(err.localizedDescription)
                success(false)
            }
        }
        task.resume()
    }
}

