//
//  RequestRegisterDeviceId.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 11/27/20.
//

import Foundation


/* Idempotent request to register deviceID in case it's a new user
 */
func requestRegisterDeviceId(success: @escaping (Bool) -> Void) {
    //http://161.35.6.60/no_sign_in/?deviceID={}
    let queryParameters = "?deviceID=" + sharedUser.deviceID
    
    let requestUrl = baseUrl + "no_sign_in/" + queryParameters
    print(requestUrl)
    let request = URLRequest(url: URL(string: requestUrl)!)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("something went wrong in fetching get_tickers/ request")
            return
        }
        
        var decodedResponse: RegisterDeviceResponse?
        do {
            decodedResponse = try JSONDecoder().decode(RegisterDeviceResponse.self, from: data!)
        } catch {
//            print("something went wrong in decoding get_tickers/ response")
            print("error in decoding \(error.localizedDescription)")
            success(false)
        }
        
        sharedUser.userId = decodedResponse!.userID
        success(true)
    }
    task.resume()
}

struct RegisterDeviceResponse : Codable {
    var userID: String
}
