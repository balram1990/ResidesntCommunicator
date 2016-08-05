//
//  LocationManager.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 01/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import CoreLocation

class LocationManager : NSObject,CLLocationManagerDelegate {

    var isWorking = false
    var locationStatus : NSString = "Not Started"
    var manager : CLLocationManager?
    var isUpdateInProgress = false
    func startLocationUpdate () {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        if  CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            manager?.startUpdatingLocation()
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func stopLocationUpdate () {
        if isWorking {
            isWorking = !isWorking
            manager?.stopUpdatingLocation()
        }
    }
    
    //MARK: CLLocationManagerDelegate
    @objc func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Error while updating the location, \(error)")
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.stopLocationUpdate()
        print("Did update new location, \(newLocation)")
        let appdelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appdelegate?.location = newLocation
        if let user  = appdelegate?.getUser(){
            if isUpdateInProgress {
                return
            }
            isUpdateInProgress = true
            let location = ["latitude" : newLocation.coordinate.latitude, "longitude" : newLocation.coordinate.longitude]
            let completeURL =  Constants.LOCATION_UPDATE_URL  + String(format: "%d", user.userID!) + "?token=" + user.token!
                NetworkIO().post(completeURL, json: location) { (data, response, error) in
                    self.isUpdateInProgress = false
                    if error != nil {
                        print("error while updating location to server, \(error)")
                    }else {
                        if let httpResonse =  response as? NSHTTPURLResponse {
                            let code =  httpResonse.statusCode
                            
                            if code == 400 || code == 404 {
                                print("Somethong wrong happened")
                            } else if code == 200 {
                                print("successfully updated location to server")
                            }
                        }
                    }
                    
                    
            }
        }
        //push new location to server
    
        
        
    }
    
    // authorization status
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            manager.startUpdatingLocation()
            self.isWorking = true
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
}
