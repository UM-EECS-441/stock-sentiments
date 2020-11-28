//
//  SearchResult.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/25/20.
//

import Foundation

class SearchResult {
    var symbol: String
    var name: String
    var count: Int
    
    init(tickerSymbol: String, tickerName: String, count: Int) {
        self.symbol = tickerSymbol
        self.name = tickerName
        self.count = count
    }
}
