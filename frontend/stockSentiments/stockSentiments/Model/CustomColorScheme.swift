//
//  CustomColorScheme.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 11/8/20.
//

import Foundation
import UIKit


// Extension for color adjustment
extension UIColor {
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}


// Custom Color Scheme for StockSentiments
struct CustomColorScheme {
    static let sharedColorScheme = CustomColorScheme()
    
    let red: UIColor = .red
    let green = UIColor(red: CGFloat(0/255.0), green: CGFloat(131/255.0), blue: CGFloat(0/255.0), alpha: CGFloat(1.0))
    let orange: UIColor = .orange
    
    
    func getSecondary(of color: UIColor) -> UIColor? {
        let amt: CGFloat = 30.0
        return color.adjust(by: abs(amt))
    }
}

// singleton instance of color scheme
let customColorScheme = CustomColorScheme.sharedColorScheme
