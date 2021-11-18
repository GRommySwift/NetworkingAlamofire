//
//  LoginViewController.swift
//  Networking
//
//  Created by Roman Holovai on 23.10.2021.
//  Copyright © 2021 Roma Holovai. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import GoogleSignIn
import Alamofire

class LoginViewController: UIViewController {
    
    
    var userProfile: UserProfile?
    
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    
    lazy var customFBLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hexValue: "#3b5999", alpha: 1)
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 360+80, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var googleLoginButton: GIDSignInButton = {
       let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 32, y: 520, width: view.frame.width - 64, height: 50)
        loginButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var customGoogleLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 520 + 80, width: view.frame.width - 64, height: 50)
        loginButton.backgroundColor = .white
        loginButton.setTitle("Login with Google", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.gray, for: .normal)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var signInWithEmail: UIButton = {
        
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.setTitle("Sign In with Email", for: .normal)
        loginButton.addTarget(self, action: #selector(openSignInVC), for: .touchUpInside)
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
        view.addSubview(customFBLoginButton)
        view.addSubview(googleLoginButton)
        view.addSubview(customGoogleLoginButton)
        view.addSubview(signInWithEmail)
    }
    
}

extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
       
        if error != nil {
            print(error!)
            return
        }
        guard AccessToken.isCurrentAccessTokenActive else { return }
        print("Succes logged with facebook")
        signIntoFirebase()
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    
        print("Succes logout")
        
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func openSignInVC() {
        performSegue(withIdentifier: "SignIn", sender: self)
    }
    
    @objc private func handleCustomFBLogin() {
        LoginManager().logIn(permissions: [ "email", "public_profile"], from: self) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return }
            else {
                self.signIntoFirebase()
            }
        }
    }
    
    private func signIntoFirebase() {
        let accesToken = AccessToken.current
        
        guard let accesTokenString = accesToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accesTokenString)
        
        Auth.auth().signIn(with: credentials) { user, error in
            if let error = error {
                print("Something went wrong with our facebook user: \(error)")
                return
            }
            
            print("Successfully loggen in with Facebook")
            self.fetchFacebookFields()
        }
    }
    
    private func fetchFacebookFields() {
        GraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, email"]).start { _, result, error in
            if let error = error {
                print(error)
                return
            }
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                print(self.userProfile?.name ?? "nil")
                self.saveIntoFirebase()
            }
        }
        
    }
    
    private func saveIntoFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name": userProfile?.name, "email": userProfile?.email]
        
        let values = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(values) { error, _ in
            if let error = error {
                print(error)
                return
            }
            
            print("Succesfully saved user data into firebase")
            self.openMainViewController()
        }
    }
    
    
    
@objc private func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
              print(error.localizedDescription)
            return
          }

                if let userName = user?.profile?.name, let userEmail = user?.profile?.email {
                    let userData = ["name": userName, "email": userEmail]
                    userProfile = UserProfile(data: userData)
                }
                
          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

          // Firebase Auth...
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print(error.localizedDescription)
                      return
                }
        // Displaying User name ...
                    
                    guard let user = result?.user else { return }
                    print(user.displayName ?? "Success")
                    self.saveIntoFirebase()
            }
                
        }
    }
}
