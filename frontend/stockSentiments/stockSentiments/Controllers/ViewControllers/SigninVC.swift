//
//  SigninVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 11/10/20.
//

import Foundation
import UIKit
import GoogleSignIn

let signinStoryboard: UIStoryboard = UIStoryboard(name: "Signin", bundle: nil)

class SigninVC: UIViewController, GIDSignInDelegate {
    
//    var returnDelegate: ReturnDelegate? = nil
    var pVC: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // set SigninVC as the delegate for GIDSignIn.sharedInstance()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user, which triggers
        // the sign(_:didSignInFor:withError:) delegate method
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    // GIDSignIn delegate function that checks if past signin can be restored, else renders button
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                // This means no previous SignIn could be restored; user has disconnected()?
                // Add a Google Sign-in button centered on your screen
                let signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
                signInButton.center = view.center
                view.addSubview(signInButton)
            } else {
                print("\(error.localizedDescription)")
            }
        } else {
            sharedUser.idToken = user.authentication.idToken
            requestSignin(sharedUser.idToken) { (successfullySignedIn) in
                if !successfullySignedIn {
                    fatalError("Failed to sign in user")
                }
                if let pVC = self.pVC as? MainVC {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            pVC.presentSignedIn()
                        }
                    }
                }
            }
        }
        return
    }
}
