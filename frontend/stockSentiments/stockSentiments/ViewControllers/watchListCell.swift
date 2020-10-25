//
//  watchListCell.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 10/25/20.
//

import UIKit

class watchListCell: UITableViewCell {

    var renderChatt: (() -> Void)? // a closure
    @IBOutlet weak var sentimentButton: UIButton!
    @IBAction func sentimentTapped(_ sender: Any) {
        self.renderChatt?()
    }

    @IBOutlet weak var stockName: UILabel!
    @IBOutlet weak var sentimentScore: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
