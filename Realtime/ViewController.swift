//
//  ViewController.swift
//  Realtime
//
//  Created by Priyank Vasa (300872404) on 2016-11-29.
//  Copyright © 2016 Matrians. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {

    var userId: String?
    var fullName: String?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "MapViewSegue") {
            //get a reference to the destination view controller
            let mapVC: MapKitViewController = segue.destinationViewController as! MapKitViewController
            
            //set properties on the destination view controller
            
            mapVC.userId = self.userId
            mapVC.fullName = self.fullName
            mapVC.email = self.email
        }
    }
    
    func loadMapView(userId: String, fullName: String, email: String) {
        self.fullName = fullName
        self.userId = userId
        self.email = email
        self.performSegueWithIdentifier("MapViewSegue", sender: self)
    }
}
