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
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }


    
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
    func handleAction(withIdentifier identifier: String?, forRemoteNotification remoteNotification: [AnyHashable: Any]) {
        let root = WKExtension.shared().rootInterfaceController
        //make session to save the notifcaiton in in iOS app
        if (WCSession.isSupported()) {
            let session : WCSession = WCSession.default()
            session.delegate = self
            session.activate()
            session.sendMessage(["message": "saveNotification", "notification" : remoteNotification], replyHandler: { (data) in
                root?.pushController(withName: "MessageDetails", context: data)
            })
        }
    }
    //Called in Active mode
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        
    }

}
