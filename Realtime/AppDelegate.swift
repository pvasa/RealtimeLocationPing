//
//  AppDelegate.swift
//  Realtime
//
//  Created by Priyank Vasa (300872404) on 2016-11-29.
//  Copyright © 2016 Matrians. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Configure Firebase
        FIRApp.configure()
        
        // Initialize Google sign-in
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    // Called when user clicks Google SignIn button
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        
        if (error == nil) { // Login successful
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            
            //let idToken = user.authentication.idToken // Safe to send to the server
            
            let fullName = user.profile.name
            
            //let givenName = user.profile.givenName
            
            //let familyName = user.profile.familyName
            
            let email = user.profile.email
            
            let viewController: ViewController = self.window?.rootViewController as! ViewController
            
            // Load the MapKitViewController on successful login
            viewController.loadMapView(userId, fullName: fullName, email: email)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
}

