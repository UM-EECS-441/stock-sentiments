//
//  ViewController.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/12/20.
//

import UIKit
import GoogleSignIn

let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)



class MainVC: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var noSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appTitleLabel.textColor = .label
        appTitleLabel.center.x = view.center.x // Place it in the center x of the view.
        appTitleLabel.center.x -= view.bounds.width // Place it on the left of the view with the width = the bounds'width of the view.
        // animate it from the left to the right
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.appTitleLabel.center.x += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("vieewDidAppear")
        setupSignIn()
    }

    @IBAction func guestTapped() {
        print("Continue without sign in tapped")
        requestRegisterDeviceId { (success) in
            if success {
                print("userId is set to after continuing without sign in:", sharedUser.userId)
                DispatchQueue.main.async {
                    self.presentSignedInView()
                }
            } else {
                fatalError("Failed to register deviceID in the backend")
            }
        }

    }

    func setupSignIn() {
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
                view.addSubview(signInButton)
                signInButton.centerXToSuperview()
                signInButton.bottomToTop(of: noSignInButton, offset: -25, isActive: true)
            } else {
                print("\(error.localizedDescription)")
            }
        } else {
            guard let userEmail = GIDSignIn.sharedInstance()?.currentUser.profile.email else {
                fatalError("Failed to retrieve user's email")
            }
            sharedUser.email = userEmail
            sharedUser.idToken = user.authentication.idToken
            requestSignin(token: sharedUser.idToken, email: sharedUser.email) { (successfullySignedIn) in
                if !successfullySignedIn {
                    fatalError("Failed to sign in user")
                }
                DispatchQueue.main.async {
                    self.presentSignedInView()
                }
            }
        }
        return
    }

    func presentSignedInView() {
        guard let tabBarController = tabBarStoryboard.instantiateViewController(identifier: "TabBarController") as? TabBarController else {
            fatalError("failed to load TabBarController")
        }

        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
}
