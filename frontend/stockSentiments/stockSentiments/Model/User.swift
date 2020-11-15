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
    var deviceID: String? = nil // unique device id
    var userId: String? = nil   // backend reference for user
    var idToken: String? = nil  // user's OpenID ID Token, a JSon Web Token (JWT)
    
    
    // request watchlist and store in watchlist member variable
    func requestAndUpdateUserWatchlist(autoReset: Bool, sortType: String, completion: @escaping () -> Void) -> Void {
        
        // this exists because there are some cases when manual reset is desired (refresh control)
        if autoReset {
            self.resetWatchlist()
        }
        
        requestUserWatchlist(completionHandler: { (watchlistResponseList) -> Void in
            // store watchlist in user instance
            for codableWatchlistItem in watchlistResponseList {
                self.watchlist[codableWatchlistItem.symbol] = Ticker(fromCodable: codableWatchlistItem)
            }
<<<<<<< HEAD
            if (sortType == "Decreasing Sentiment Score"){
                // set ordering by decreasing sentiment score
                self.orderedWatchlistKeys = Array(user.watchlist.keys).sorted(by: { (lhs, rhs) -> Bool in
                    return self.watchlist[lhs]!.sentimentScore > self.watchlist[rhs]!.sentimentScore
                })
            }
            else if(sortType == "Increasing Sentiment Score"){
                // set ordering by increasing sentiment score
                self.orderedWatchlistKeys = Array(user.watchlist.keys).sorted(by: { (lhs, rhs) -> Bool in
                    return self.watchlist[rhs]!.sentimentScore > self.watchlist[lhs]!.sentimentScore
                })
            }
            else if(sortType == "Decreasing Alphabetical"){
                // set ordering by decreasing sentiment score
                self.orderedWatchlistKeys = Array(user.watchlist.keys).sorted(by: { (lhs, rhs) -> Bool in
                    return self.watchlist[lhs]!.name > self.watchlist[rhs]!.name
                })
            }
            else if(sortType == "Increasing Alphabetical"){
                // set ordering by increasing sentiment score
                self.orderedWatchlistKeys = Array(user.watchlist.keys).sorted(by: { (lhs, rhs) -> Bool in
                    return self.watchlist[rhs]!.name > self.watchlist[lhs]!.name
                })
            }
            else if(sortType == "Recently Added"){
                    // set ordering by recently added timestamp
                    self.orderedWatchlistKeys = Array(user.watchlist.keys).sorted(by: { (lhs, rhs) -> Bool in
                        return self.watchlist[rhs]!.timestamp > self.watchlist[lhs]!.timestamp
                    })
                }
            else{
                // default
                // set ordering by decreasing sentiment score
                self.orderedWatchlistKeys = Array(user.watchlist.keys).sorted(by: { (lhs, rhs) -> Bool in
                    return self.watchlist[lhs]!.sentimentScore > self.watchlist[rhs]!.sentimentScore
                })
            }
=======
            // set ordering by decreasing sentiment score
            self.orderedWatchlistKeys = Array(self.watchlist.keys).sorted(by: { (lhs, rhs) -> Bool in
                return self.watchlist[lhs]!.sentimentScore > self.watchlist[rhs]!.sentimentScore
            })
            
>>>>>>> WIP signin. Bug: GIDSignin.sharedInstance() isn't saving idToken.
            // call completion strictly after we have updated user's watchlist
            completion()
        })
    }
    
    func resetWatchlist() {
        self.watchlist.removeAll()
        self.orderedWatchlistKeys.removeAll()
    }
}

// singleton instance of user
let sharedUser = User.sharedUser
