//
//  SentimentColor.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/26/20.
//

import Foundation
import UIKit


// single source of truth for setting associated colors
enum SentimentLabel : String {
    case negative = "negative"
    case positive = "positive"
    case neutral = "neutral"
    
    var color: UIColor {
        get {
            switch self {
            case .negative:
                return customColorScheme.red
            case .positive:
                return customColorScheme.green
            case .neutral:
                return customColorScheme.orange
            }
        }
    }

    var emoji: String {
        get {
            switch self {
            case .negative:
                return "🙁"
            case .positive:
                return "😀"
            case .neutral:
                return "😐"
            }
        }
    }
}

func getSentimentLabel(score sentimentScore: Double) -> SentimentLabel {
    if sentimentScore < -0.33 {
        return .negative
    } else if sentimentScore > 0.33 {
        return .positive
    }
    return .neutral
}
