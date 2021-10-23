//
//  LoginViewController.swift
//  Networking
//
//  Created by Roman Holovai on 23.10.2021.
//  Copyright © 2021 Roma Holovai. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 320, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        setupViews()
        if AccessToken.isCurrentAccessTokenActive {
            print("The user is logged in")
        }
            
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
    }

}

extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
       
        if error != nil {
            print(error!)
            return
        }
        print("Succes logged with facebook")
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    
        print("Succes logout")
        
    }
    
    
}
