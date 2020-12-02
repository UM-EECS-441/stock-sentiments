//
//  ViewController.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/12/20.
//

import UIKit
import GoogleSignIn

let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)



class MainVC: UIViewController/*, ReturnDelegate */{

    @IBOutlet weak var signinButton: CustomButton!
    @IBOutlet weak var appTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        signinButton.tintColor = .systemBlue
        appTitleLabel.textColor = .label
        appTitleLabel.center.x = view.center.x // Place it in the center x of the view.
        appTitleLabel.center.x -= view.bounds.width // Place it on the left of the view with the width = the bounds'width of the view.
        // animate it from the left to the right
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.appTitleLabel.center.x += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
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
            guard let userEmail = GIDSignIn.sharedInstance()?.currentUser.profile.email else {
                fatalError("Failed to retrieve user's email")
            }
            sharedUser.email = userEmail
            requestSignin(token: GIDSignIn.sharedInstance().currentUser.authentication.idToken!, email: sharedUser.email) { (successfullySignedIn) in
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
        print("Continue without sign in tapped")
        requestRegisterDeviceId { (success) in
            if success {
                print("userId is set to after continuing without sign in:", sharedUser.userId)
                DispatchQueue.main.async {
                    self.presentSignedIn()
                }
            } else {
                fatalError("Failed to register deviceID in the backend")
            }
        }

    }

    func presentSignedIn() {
        guard let tabBarController = tabBarStoryboard.instantiateViewController(identifier: "TabBarController") as? TabBarController else {
            fatalError("failed to load TabBarController")
        }

        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
}
