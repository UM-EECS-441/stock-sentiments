//
//  SearchResult.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/25/20.
//

import Foundation

// TODO: delete this and just use a string unless we find more uses for this
class SearchResult {
    var symbol: String
    var name: String
    
    init(tickerSymbol: String, tickerName: String) {
        self.symbol = tickerSymbol
        self.name = tickerName
    }
}
