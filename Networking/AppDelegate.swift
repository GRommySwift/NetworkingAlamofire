//
//  AppDelegate.swift
//  Networking
//
//  Created by Roman Holovai on 19.10.2021.
//



import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

let primaryColor = UIColor(red: 62/255, green: 233/255, blue: 153/255, alpha: 1)
let secondaryColor = UIColor(red: 90/255, green: 183/255, blue: 242/255, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var bgSessionCompletionHandler: (() -> ())?

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        bgSessionCompletionHandler = completionHandler
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        return true
    }
          
    func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

//        ApplicationDelegate.shared.application(app,open: url,sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )
          return GIDSignIn.sharedInstance.handle(url)
        
    }
}


