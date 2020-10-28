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
    var orderedWatchlistKeys = [String]() // array of ticker symbols (to maintain ordering in watchlist table view)
    
    // MARK:- User Identity
    // verify that is is a valid way to do deviceID https://www.hackingwithswift.com/example-code/system/how-to-identify-an-ios-device-uniquely-with-identifierforvendor
    var deviceID: String? = nil
    var username: String? = nil
    var password: String? = nil
    
    
    func requestAndUpdateUserWatchlist(completion: @escaping () -> Void) -> Void {
        // request watchlist and store in watchlist member variable
        requestUserWatchlist(completionHandler: { (watchlistResponseList) -> Void in
//            self.watchlistInstance = watchlist
            // store watchlist in user instance
            for codableWatchlistItem in watchlistResponseList {
                self.watchlist[codableWatchlistItem.symbol] = Ticker(fromCodable: codableWatchlistItem)
            }
            // set ordering
            self.orderedWatchlistKeys = Array(user.watchlist.keys)
            
            // call completion strictly after we have updated user's watchlist
            completion()
        })
    }
}

// singleton instance of user
let user = User.sharedUser
