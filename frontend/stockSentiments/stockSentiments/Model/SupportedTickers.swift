//
//  SupportedTickers.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/25/20.
//


/* Caches a dictionaries of supported tickers after user opens Search View for the first
 time. Stores both symbol and name as keys. This should be a singleton instance in SearchVC
 */
class SupportedTickers {
    var symbolToName: [String:String] = [:]
    var nameToSymbol: [String:String] = [:]
    
    var allPossibleQueries: [String] = []

    init(response responseData : [TickerResponse]) {
        
        for tickerResponse in responseData {
            nameToSymbol[tickerResponse.name] = tickerResponse.symbol
            symbolToName[tickerResponse.symbol] = tickerResponse.name
        }
        
    }
}
