//
//  ExtensionDelegate.swift
//  ResidentWKApp WatchKit Extension
//
//  Created by Balram Singh on 31/07/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    
    //Handle remote notificaton when user clickes on view button on watchkip app
    func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        let root = WKExtension.sharedExtension().rootInterfaceController
        //make session to save the notifcaiton in in iOS app
        if (WCSession.isSupported()) {
            let session : WCSession = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            session.sendMessage(["message": "saveNotification", "notification" : remoteNotification], replyHandler: { (data) in
                root?.pushControllerWithName("MessageDetails", context: data)
                }, errorHandler: { (error) in
                    root?.showFailure(error.code)
            })
        }
        
    }
    
    //Called in Active mode
    func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        
    }

}
