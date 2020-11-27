//
//  Sentiment.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 11/27/20.
//

import Foundation

// stores all relevant information for a specific sentiment
class Sentiment {
    var ticker: String
    var sentiment: Double
    var time: String
    var price: Double

    init(ticker: String, sentiment: Double, time: String, price: Double) {
        self.ticker = ticker
        self.sentiment = sentiment
        self.time = time
        self.price = price
    }

    // initialize from Codable response format
    init(fromCodable codable: Data) {
        self.ticker = codable.ticker
        self.sentiment = codable.sentiment
        self.time = codable.time
        self.price = codable.price
    }
}
