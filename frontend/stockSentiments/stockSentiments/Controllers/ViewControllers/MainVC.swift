//
//  ViewController.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/12/20.
//

import UIKit
import GoogleSignIn

protocol ReturnDelegate: UIViewController {
    func didReturn(_ result: String)
}

class MainVC: UIViewController/*, ReturnDelegate */{
    
    @IBOutlet weak var signinButton: CustomButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        signinButton.backgroundColor = .systemGray
        signinButton.tintColor = .systemBackground
    }
    
    @IBAction func signinButtonTapped(_ sender: Any) {
//        GIDSignIn.sharedInstance()?.signOut() // TODO: del
        if (GIDSignIn.sharedInstance()?.currentUser == nil) {
            // user is not signed in
            guard let signinVC = signinStoryboard.instantiateViewController(identifier: "SigninVC") as? SigninVC else {
                print("failed to load signinVC")
                return
            }
            signinVC.pVC = self
            
            present(signinVC, animated: true, completion: nil)
        } else {
            requestSignin(GIDSignIn.sharedInstance().currentUser.authentication.idToken!) { (successfullySignedIn) in
                if !successfullySignedIn {
                    fatalError("Failed to sign in user")
                }
                DispatchQueue.main.async {
                    self.presentSignedIn()
                }
            }
        }
    }
    
    @IBAction func guestTapped() {
        print("tapped")
        self.presentSignedIn()
    }
    
    func presentSignedIn() {
        guard let tabBarController = tabBarStoryboard.instantiateViewController(identifier: "TabBarController") as? TabBarController else {
            print("failed to load TabBarController")
            return
        }

        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
}

