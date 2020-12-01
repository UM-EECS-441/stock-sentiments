//
//  MyCustomCell.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 11/30/20.
//

import UIKit

class MyCustomCell: UITableViewCell {

    @IBOutlet weak var settingsLabel: UILabel!
    
    @IBOutlet weak var switchButton: UISwitch!

    @IBAction func switchToggled(_ sender: UISwitch) {
        print(sender.isOn)
        if(sender.isOn){
            // do something
            print("email notification is on")
            sharedUser.notification = true
            print(sharedUser.notification)
            //call email toggle post/request method
        }
        else{
            // do something
            print("email notification is off")
            sharedUser.notification = false
            //call email toggle post/request method
            print(sharedUser.notification)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
