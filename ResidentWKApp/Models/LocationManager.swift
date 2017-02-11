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
    var isPollInProgress = false
    var lastUpdateTime : Date?
    var lastPollTime : Date?
    func startLocationUpdate () {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if  CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            manager?.startUpdatingLocation()
            //start asking for location
            self.startPoll()
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
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        //keep checking for location request from server 
        self.startPoll()
        
        if let _ = lastUpdateTime {
            let interval = -(lastUpdateTime!.timeIntervalSinceNow)
            if (appdelegate?.assitanceCalled == true){
                if interval < 60 {
                    return
                }else {
                    let assitanceCalledTime = appdelegate?.assitanceCalledTime!
                    let timeTillLocationHasToBeSend = assitanceCalledTime?.addingTimeInterval(3600)
                    if Date() > timeTillLocationHasToBeSend! {
                        appdelegate?.assitanceCalled = false
                        appdelegate?.assitanceCalledTime = nil
                        return
                    }
                }
            }else {
                if (interval < 3600 ) {
                    return
                }
            }
        }
        let newLocation = locations.last
        print("Did update new location, \(newLocation)")
        
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
                    self.lastUpdateTime = Date()
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
    
    func startPoll () {
        if self.isPollInProgress {
            return
        }
        if let _ = lastPollTime {
            let interval = -(lastPollTime!.timeIntervalSinceNow)
            if interval < 120 {
                return
            }
        }
        lastPollTime = Date()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let user  = appDelegate?.getUser() {
            self.isPollInProgress = true
            let completeURL =  Constants.CHECK_LOCATION_URL  + String(format: "%d", user.userID!) + "?token=" + user.token!
            NetworkIO().get(completeURL) { (data, response, error) in
                self.isPollInProgress = false
                if error != nil {
                    print("Error while fetching status from server")
                }else {
                    print("Check Poll URL response \(data)")
                    if data?["sendtime"] as? Bool == true {
                        let location = ["latitude" : appDelegate?.location?.coordinate.latitude, "longitude" : appDelegate?.location?.coordinate.longitude]
                        let completeURL =  Constants.LOCATION_UPDATE_URL  + String(format: "%d", user.userID!) + "?token=" + user.token!
                        NetworkIO().post(completeURL, json: location as NSDictionary?) { (data, response, error) in
                            if error != nil {
                                print("error while updating location to server through polling, \(error)")
                            }else {
                                print("successfully updated location to server through polling")
                            }
                        }
                    }
                    
                }

            }
        }
       
    }
}
