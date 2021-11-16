//
//  UserProfileVC.swift
//  Networking
//
//  Created by Roman Holovai on 23.10.2021.
//  Copyright © 2021 Roma Holovai. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase

class UserProfileVC: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32,
                                   y: view.frame.height - 172,
                                   width: view.frame.width - 64,
                                   height: 50)
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        userNameLabel.isHidden = true
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchingUserData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
    }
    
}


extension UserProfileVC {
    
    private func openLoginViewController() {
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
        } catch let error {
            print("Fail to signOut: \(error.localizedDescription)")
        }
    }
    
    private func fetchingUserData() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let userData = snapshot.value as? [String: Any] else { return }
                self.currentUser = CurrentUser(uid: uid, data: userData)
                self.activityIndicator.stopAnimating()
                self.userNameLabel.isHidden = false
                self.userNameLabel.text = self.getProviderData()
            } withCancel: { error in
                print(error)
            }

        }
    }
    
    @objc private func signOut() {
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("User did log out of Facebook")
                    openLoginViewController()
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                    print("User did log out of Google")
                    openLoginViewController()
                default:
                    print("User is singed in with \(userInfo.providerID)")
                }
            }
        }
    }
 
    private func getProviderData() -> String {
        var greetings = ""
        
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com": provider = "Facebook"
                case "google.com": provider = "Google"
                default: break
                }
            }
            
            greetings = "\(currentUser?.name ?? "Noname") Logged in with \(provider!)"
        }
        return greetings
    }
}
