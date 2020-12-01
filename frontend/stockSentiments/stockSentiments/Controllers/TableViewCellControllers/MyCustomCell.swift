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
        requestToggleNotifications(on: sender.isOn) { (success) in
            DispatchQueue.main.async {
                if success {
                    sharedUser.notifications = sender.isOn
                } else {
                    self.switchButton.setOn(!sender.isOn, animated: true)
                }
                print("successfully toggled notifications:", success)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.switchButton.setOn(sharedUser.notifications, animated: false)
    }
}
