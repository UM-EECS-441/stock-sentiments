//
//  watch.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/25/20.
//


class WatchlistItem {
    var symbol: String
    var sentimentScore: String

    init(tickerSymbol: String, sentimentScore: String) {
        self.symbol = tickerSymbol
        self.sentimentScore = sentimentScore
    }
}


