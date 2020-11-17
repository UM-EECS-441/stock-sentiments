//
//  pickerView.swift
//  stockSentiments
//
//  Created by Sinmisola Kareem on 11/16/20.
//

import UIKit

let pickerStoryboard: UIStoryboard = UIStoryboard(name: "pickerView", bundle: nil)
protocol ReturnDelegate: UIViewController{
    func didReturn(_ result: String) // data: string is an example parameter
}

class pickerView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var returnDelegate : ReturnDelegate? // to pass return result to caller
    
    var pVC: UITableViewController? = nil // pointer to parent view controller needed to replace view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // Title for each row in component
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    // Get the selected row
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Nothing to do in this tutorial
         selectedRow = pickerData[row]
         print(selectedRow)
    }





    var selectedRow:String = ""

    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var pickerView: UIPickerView!
    var pickerData = ["Decreasing Sentiment Score", "Increasing Sentiment Score", "Decreasing Alphabetical", "Increasing Alphabetical", "Recently Added"]

    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.

            pickerView.dataSource = self
            pickerView.delegate = self
        }


    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    func getSelectedRow() -> String {
        return selectedRow
    }


    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneTapped(_ sender: Any) {
        returnDelegate?.didReturn(selectedRow)
        dismiss(animated: true, completion: nil)

    }

    // reloads table view data using the pVC pointer
    func refreshWatchlistTableViewIfIsParent() {
        if let pVC = self.pVC as? WatchlistVC {
            DispatchQueue.main.async {
                pVC.tableView.reloadData()
            }
        }
    }


}
