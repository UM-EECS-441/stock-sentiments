//
//  User.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/24/20.
//


// Singleton instance per app lifecycle
class User {
    
    static let sharedUser = User()
    
    // Stores the user's current Watchlist. This should always be updated when in watchlist view
    // TODO: on subscribe and unsubscribe and on refresh ??: discard and reload watchlist
    var watchlist = [String:Ticker]() // symbol -> Ticker map
    
    // MARK:- User Identity
    // verify that is is a valid way to do deviceID https://www.hackingwithswift.com/example-code/system/how-to-identify-an-ios-device-uniquely-with-identifierforvendor
    var deviceID: String? = nil
    var username: String? = nil
    var password: String? = nil
}

// singleton instance of user
let user = User.sharedUser
