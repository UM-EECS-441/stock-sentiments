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
    let symbolToName: [String:String]
    let nameToSymbol: [String:String]

    init(response responseData : SupportedTickersResponseData) {
        symbolToName = responseData.dictTickers
        
        // store inverted as well
        nameToSymbol = [:]
        for (symbol, name) in symbolToName {
            nameToSymbol[name] = symbol
        }
    }
}

// Stores response of /get_tickers
struct GetSupportedTickersResponse : Codable {
    let status: String
    let data: SupportedTickersResponseData
}

// array of {symbol:name} key-val pairs
struct SupportedTickersResponseData : Codable {
    let dictTickers: [String:String]
}
