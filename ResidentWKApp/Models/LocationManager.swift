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
    let manager = CLLocationManager()
    func startLocationUpdate () {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if  CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            manager.requestWhenInUseAuthorization()
            
        }
    }
    
    func stopLocationUpdate () {
        if isWorking {
            isWorking = !isWorking
            manager.stopUpdatingLocation()
        }
    }
    
    //MARK: CLLocationManagerDelegate
    @objc func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Error while updating the location, \(error)")
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.stopLocationUpdate()
        //push new location to server
        let location = ["latitude" : newLocation.coordinate.latitude, "longitude" : newLocation.coordinate.longitude]
        NetworkIO().post(Constants.LOCATION_UPDATE_URL, json: location) { (data, response, error) in
            if error != nil {
                print("error while updating location to server, \(error)")
            }
        }
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
