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
    var lastUpdateTime : String?
    func startLocationUpdate () {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if  CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
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
    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Error while updating the location, \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let _ = lastUpdateTime {
//            let lastAttemptTime = self.getDateFormatter().date(from: lastUpdateTime!)
//            let interval = -(lastAttemptTime?.timeIntervalSinceNow)!
//            let delegate = UIApplication.shared.delegate as? AppDelegate
//            if (delegate?.assitanceCalled == true && interval < 300) || (interval < 3600 && delegate?.assitanceCalled == false){
//                return
//            }
//        }
        
        self.stopLocationUpdate()
        let newLocation = locations.last
        print("Did update new location, \(newLocation)")
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        appdelegate?.location = newLocation
        if let user  = appdelegate?.getUser(){
            if isUpdateInProgress {
                return
            }
            isUpdateInProgress = true
            let location = ["latitude" : newLocation?.coordinate.latitude, "longitude" : newLocation?.coordinate.longitude]
            let completeURL =  Constants.LOCATION_UPDATE_URL  + String(format: "%d", user.userID!) + "?token=" + user.token!
            NetworkIO().post(completeURL, json: location as NSDictionary?) { (data, response, error) in
                self.isUpdateInProgress = false
                if error != nil {
                    print("error while updating location to server, \(error)")
                }else {
                    print("successfully updated location to server")
                    self.lastUpdateTime = self.getStringFromDate(Date())! as String
                }
            }
        }
    }
    
    // authorization status
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
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
    
    func getDateFormatter () -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        return formatter
    }
    
    func getStringFromDate (_ date : Date ) -> NSString? {
        return self.getDateFormatter().string(from: date) as NSString?
    }
}
