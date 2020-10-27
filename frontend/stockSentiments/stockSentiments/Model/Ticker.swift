//
//  watch.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/25/20.
//


// stores all relevant information for a specific ticker
class Ticker {
    var symbol: String
    var name: String
    var sentimentScore: Double
    var timestamp: String

    init(tickerSymbol: String, tickerName: String, sentimentScore: Double, timestamp: String) {
        self.symbol = tickerSymbol
        self.name = tickerName
        self.sentimentScore = sentimentScore
        self.timestamp = timestamp
    }
}


