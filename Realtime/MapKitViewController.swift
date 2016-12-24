//
//  MapKitViewController.swift
//  Realtime
//
//  Created by Priyank Vasa (300872404) on 2016-11-29.
//  Copyright © 2016 Matrians. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapKitViewController: UIViewController, CLLocationManagerDelegate {

    // Reference to Map View
    @IBOutlet weak var mapView: MKMapView!
    
    // Instance of Location Manager
    var locationManager: CLLocationManager!
    
    // Annotation showing this users location
    var mAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    // Mapping of Annotations of other loggedin users with their ids
    var annotationMap: [String: MKPointAnnotation] = [:]
    
    var userId: String?
    var fullName: String?
    var email: String?
    
    // Reference to database
    let db = FIRDatabase.database().referenceWithPath("locations")
    
    // Set region for the first time user starts app, to zoom in
    var setRegion: Bool = true
    
    // Starts updating locations when Location permission is granted
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .AuthorizedWhenInUse:
            locationManager.distanceFilter = 10 as CLLocationDistance // Update when user moves 10 meters
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // Locaiton accuracy
            locationManager.startUpdatingLocation() // Start updating location
            break
            
        default: break
            
        }
    }
    
    // Executed when location changed
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        if (setRegion) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(
                location.coordinate, 50000, 50000)
            mapView.setRegion(coordinateRegion, animated: true)
            setRegion = false
        }
        
        // get the current date and time
        let currentDateTime = NSDate()
        
        // initialize the date formatter and set the style
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.dateStyle = .MediumStyle
        
        // Location object of current user sent to database
        let loc: [String: AnyObject] = [
            "fullName": fullName!,
            "email": email!,
            "userId": userId!,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": formatter.stringFromDate(currentDateTime)
        ]
        
        // Update new location to database
        db.child(userId!).updateChildValues(loc)
        
        // Remove old annotation
        mapView.removeAnnotation(mAnnotation)
        
        mAnnotation.coordinate = location.coordinate
        
        mAnnotation.title = fullName
        mAnnotation.subtitle = formatter.stringFromDate(currentDateTime)
        
        // Add annotation with new coordinates
        mapView.addAnnotation(mAnnotation)
        
        mapView.showsUserLocation = true
        
        //locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (CLLocationManager.locationServicesEnabled()) { // Check if Location services enabled
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization() // Request Location permission
        }
        
        // Observe ChildChanged events on FirebaseDatabase
        db.observeEventType(.ChildChanged, withBlock: { snapshot in
            
            var tmpAnnotation: MKPointAnnotation
            
            if snapshot.value != nil {
                
                let userId = snapshot.value!["userId"] as! String
                
                if (userId != self.userId) {
                
                    // Create annotation with new coordinates of updated user
                    tmpAnnotation = MKPointAnnotation()
                    tmpAnnotation.coordinate.latitude = snapshot.value!["latitude"] as! CLLocationDegrees
                    tmpAnnotation.coordinate.longitude = snapshot.value!["longitude"] as! CLLocationDegrees
                    tmpAnnotation.title = snapshot.value!["fullName"] as! NSString as String
                    tmpAnnotation.subtitle = snapshot.value!["timestamp"] as! NSString as String
                    
                    if self.annotationMap.indexForKey(userId) == nil {
                        // If new user signed into database, add his details to annotationMap
                        self.annotationMap[userId] = tmpAnnotation
                    }
                    else {
                        // Remove old annotation from Map View
                        self.mapView.removeAnnotation(self.annotationMap[userId]!)
                        
                        // Update old annotation of changed user to new annotation
                        self.annotationMap.updateValue(tmpAnnotation, forKey: userId)
                    }
                    // Add new annotation to Map View
                    self.mapView.addAnnotation(tmpAnnotation)
                }
            }
        })
    }
}
