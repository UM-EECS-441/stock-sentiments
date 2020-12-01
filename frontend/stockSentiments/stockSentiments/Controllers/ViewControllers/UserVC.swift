//
//  UserVC.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 11/30/20.
//

import UIKit

let userStoryboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
class UserVC: UIViewController{
    var pVC: UIViewController? = nil
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var email: UILabel!
    var user_id: String? = nil
    var email_id: String? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        self.userId.text = user_id
        self.email.text = email_id
    }
}
