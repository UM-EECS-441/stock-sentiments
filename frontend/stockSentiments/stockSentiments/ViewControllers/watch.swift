//
//  watch.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/25/20.
//
import UIKit

class watch{
    var stockName: String
    var sentimentScore: String



    init(stockName: String, sentimentScore: String) {
        self.stockName = stockName
        self.sentimentScore = sentimentScore
    }

}

class search{
    var tickerName: String
    init(tickerName: String) {
        self.tickerName = tickerName
    }
}
