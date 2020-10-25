//
//  searchCell.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/25/20.
//

import UIKit

class SearchCell: UITableViewCell{
    
    @IBOutlet weak var viewStock: UIButton!
    @IBOutlet weak var tickerName: UILabel!
    
    var renderSearch: (() -> Void)? // a closure
    
    @IBAction func stockTapped(_ sender: Any) {
        self.renderSearch?()
    }
}
