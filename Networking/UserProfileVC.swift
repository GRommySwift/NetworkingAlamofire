//
//  UserProfileVC.swift
//  Networking
//
//  Created by Roman Holovai on 23.10.2021.
//  Copyright © 2021 Roma Holovai. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class UserProfileVC: UIViewController {
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32,
                                   y: view.frame.height - 172,
                                   width: view.frame.width - 64,
                                   height: 50)
        loginButton.delegate = self
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        setupViews()
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

//MARK: Facebook SDK

extension UserProfileVC: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
       
        if error != nil {
            print(error!)
            return
        }
        print("Succes logged with facebook")
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    
        print("Succes logout")
        
        openLoginViewController()
        
    }
    
    private func openLoginViewController() {
        if !(AccessToken.isCurrentAccessTokenActive) {
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
        }
    }
    
}
