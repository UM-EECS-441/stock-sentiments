//
//  SettingsVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit
import GoogleSignIn

let settingsStoryboard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
class SettingsVC: UITableViewController, UITabBarDelegate {

//    @IBOutlet weak var emailLabel: UILabel!
    
    
    let settings: [String] = ["Signed in with ", "Receive Email Notifications", "Log Out"]


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    /*Table View */
    // number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return self.settings.count
       }

       // create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

       let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: "MyCustomCell") as! MyCustomCell
    //
        switch (indexPath.row) {
        case 0:
            let account = sharedUser.email != "" ? sharedUser.email : "guest"
            cell.settingsLabel.text = settings[indexPath.row] + account
            cell.settingsLabel.sizeToFit()
            cell.switchButton.isHidden = true
            cell.switchButton.sizeToFit()
        case 1:
            // receive notifications
            if sharedUser.email != "" { // only show this cell if the user is signed in
                cell.settingsLabel.text = settings[indexPath.row]
                cell.settingsLabel.sizeToFit()
                cell.switchButton.isHidden = false
                cell.switchButton.sizeToFit()
            } else {
                cell.isHidden = true
            }
            break
        case 2:
            // LogOut
            cell.settingsLabel.text = settings[indexPath.row]
            cell.settingsLabel.sizeToFit()
            cell.switchButton.isHidden = true
            cell.switchButton.sizeToFit()
            break
        
        default:
            cell.settingsLabel.text = settings[indexPath.row]
            cell.settingsLabel.sizeToFit()
            cell.switchButton.isHidden = true
            cell.switchButton.sizeToFit()
            break
    }

        return cell
    }

       // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           print("You tapped cell number \(indexPath.row).")
        switch (indexPath.row) {
        case 0:
            // receive notifications
            break
        case 1:
            // receive notifications
            break
        case 2:
            // LogOut
            // clear sharedUser instance besides deviceID
            sharedUser.email = ""
            sharedUser.idToken = ""
            sharedUser.userId = ""

            // call GID sign out function
            GIDSignIn.sharedInstance()?.signOut()
            self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
   }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set nav title and don't allow back functionality
        self.tabBarController?.navigationItem.title = "Settings"
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
    }

}
