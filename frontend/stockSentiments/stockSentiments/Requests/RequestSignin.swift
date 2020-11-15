//
//  RequestSignin.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 11/14/20.
//

import Foundation


func requestSignin(_ idToken: String) {
    /* until backend verification is completed, the function should simply
    return
    */
    /**/
    if sharedUser.userId == "" {
        // obtain chatterID from backend, replace the following line
        let json: [String: Any] = ["clientID": signinClientID,
                                   "idToken" : idToken]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Replace YOUR_SERVER_IP with the IP address of your droplet
        var request = URLRequest(url:
            URL(string: baseUrl + "signin/")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task =  URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                // TODO4.1: Case 5'a: for chatterID, pass an empty string "" back to MainVC
//                self.returnDelegate?.didReturn("")
                sharedUser.userId = ""
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                // TODO4.2: Case 5'b: return an empty string "" as chatterID to MainVC
//                self.returnDelegate?.didReturn("")
                sharedUser.userId = ""
                
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!)
                    as? [String:Any] {
                    // Case 4 in the **above** figure.
                    sharedUser.userId = json["userID"] as? String ?? ""
                    // TODO4.3: Case 5 (figure **below**): return self.chatterID to MainVC
//                    self.returnDelegate?.didReturn(self.chatterID)
                }
            } catch let err {
                // TODO4.4: Case 5'c: return an empty string "" as chatterID to MainVC
//                self.returnDelegate?.didReturn("")
                sharedUser.userId = ""
                print(err.localizedDescription)
            }
        }
        task.resume()
    } // else no need to call return delegate
    /**/
}

