//
//  watch.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/25/20.
//


class WatchlistItem {
    var symbol: String
    var name: String
    var sentimentScore: Int
    var timestamp: String

    init(tickerSymbol: String, tickerName: String, sentimentScore: Int, timestamp: String) {
        self.symbol = tickerSymbol
        self.name = tickerName
        self.sentimentScore = sentimentScore
        self.timestamp = timestamp
    }
}


