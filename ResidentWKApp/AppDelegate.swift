//
//  AppDelegate.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 31/07/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate {

    var window: UIWindow?

    var locationManager : LocationManager?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        PushNotificationManager.pushManager().delegate = self
        PushNotificationManager.pushManager().handlePushReceived(launchOptions)
        PushNotificationManager.pushManager().sendAppOpen()
        PushNotificationManager.pushManager().registerForPushNotifications()
        locationManager = LocationManager()
        locationManager?.startLocationUpdate()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let viewAction = UIMutableUserNotificationAction()
        viewAction.identifier = "VIEW_IDENTIFIER"
        viewAction.title = "View"
        viewAction.activationMode = .Foreground
        let category = UIMutableUserNotificationCategory()
        category.identifier = "MESSAGE_CATEGORY"
        category.setActions([viewAction], forContext: .Default)
        
        
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: [category])
        application.registerUserNotificationSettings(notificationSettings)
    }

    //Notification registration delegates
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PushNotificationManager.pushManager().handlePushRegistration(deviceToken)
//        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
//        var tokenString = ""
//        
//        for i in 0..<deviceToken.length {
//            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
//        }
//        
//        print("Device Token:", tokenString)
//        NetworkIO().post(Constants.TOKEN_UPDATE_URL, json: ["token" : tokenString]) { (data, response, error) in
//            if error != nil {
//                print("failed to update token to server, \(error)")
//            }
//        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
        PushNotificationManager.pushManager().handlePushRegistrationFailure(error)
    }
    
    //push notification services delegate
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        PushNotificationManager.pushManager().handlePushReceived(userInfo)
        let aps = userInfo["aps"] as! [String: AnyObject]
        print("did receive notification \(aps)")
    
        //createNewNewsItem(aps)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        // 1
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // 2
//        if let newsItem = createNewNewsItem(aps) {
//            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//            
//            // 3
//            if identifier == "VIEW_IDENTIFIER", let url = NSURL(string: newsItem.link) {
//                let safari = SFSafariViewController(URL: url)
//                window?.rootViewController?.presentViewController(safari, animated: true, completion: nil)
//            }
//        }
        
        // 4
        completionHandler()
    }
    
    func onPushAccepted(pushManager: PushNotificationManager!, withNotification pushNotification: [NSObject : AnyObject]!, onStart: Bool) {
        print("Push notification accepted: \(pushNotification)");
    }
    

}

