//
//  AuthenticationViewController.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit

@objc protocol AuthenicationDelegate {
    func authenticationViewController(viewController : AuthenticationViewController, didLoginWithAccount account: Account)
    func authenticationViewControllerDidCancel(viewcontroller : AuthenticationViewController)
}

class AuthenticationViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    @IBAction func didTapSignIn(sender: AnyObject) {
        let username = usernameField.text
        SignInAccount().api.authenticateWithUsername(username, password: passwordField.text) {
            (success, error, token, secret) in
            if success {
                let account = AccountManager.sharedManager.addAccount(username, token: token!, secret: secret!)
                self.delegate?.authenticationViewController(self, didLoginWithAccount: account)
            } else {
                println("epic failure")
            }
        }
    }
    weak var delegate : AuthenicationDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.addTarget(self, action: "fieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
        passwordField.addTarget(self, action: "fieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
        self.revalidate()
    }

    func fieldChanged(sender: AnyObject){
        self.revalidate()
    }

    func revalidate() {
        if usernameField.text.utf16Count > 0 && passwordField.text.utf16Count > 0 {
            signInButton.enabled = true
        } else {
            signInButton.enabled = false
        }
    }

    @IBAction func didClickCancel(sender: AnyObject) {
        delegate?.authenticationViewControllerDidCancel(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        println("Loading: \(request.URL)")
        return true
    }
}
