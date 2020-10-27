//
//  Watchlist.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/24/20.
//


/* Stores a list of Ticker instances */
class Watchlist {
    var watchlist: [Ticker] = []
    
    init(response responseData: [WatchlistResponse]) {
        
        for watchlistResponse in responseData {
            watchlist.append(
                Ticker(tickerSymbol: watchlistResponse.symbol,
                       tickerName: watchlistResponse.name,
                       sentimentScore: watchlistResponse.score,
                       timestamp: watchlistResponse.timestamp))
        }
    }
}
