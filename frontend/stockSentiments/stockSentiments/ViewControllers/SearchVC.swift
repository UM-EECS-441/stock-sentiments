//
//  SearchVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit

let searchStoryboard: UIStoryboard = UIStoryboard(name: "Search", bundle: nil)

class SearchVC: UITableViewController {
    
    // nil until SearchVC is instantiated for the first time
    var supportedTickers: SupportedTickers? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // completion handler has access to supportedTickers passed by delegator
        // https://stackoverflow.com/questions/30401439/how-could-i-create-a-function-with-a-completion-handler-in-swift
        requestSupportedTickers(completionHandler: { (supportedTickers) -> Void in
            self.supportedTickers = supportedTickers
        })
    }
    
}
