//
//  AppDelegate.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 31/07/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var user : User?
    var locationManager : LocationManager?
    var location : CLLocation?
    var pushToken : String?
    static let NotificationListUpdate = "NotificationListUpdate"
    var session : WCSession?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.loadData()
        // Override point for customization after application launch.
        NSLog("App Did finish launching with optipns \(launchOptions)")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.hidden = false
        PushNotificationManager.pushManager().delegate = self
        PushNotificationManager.pushManager().handlePushReceived(launchOptions)
        PushNotificationManager.pushManager().sendAppOpen()
        PushNotificationManager.pushManager().registerForPushNotifications()
        locationManager = LocationManager()
        locationManager?.startLocationUpdate()
        
        if userDefaults().objectForKey(Constants.USER_LOGGED_IN_KEY) as? NSNumber == true {
            self.user = self.getUser()
            self.launchLandingScreen()
            if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as! [NSObject : AnyObject]? {
                self.launchMessageDetailsSceen(remoteNotification)
                
            }
        } else {
            self.launchLoginScreen()
        }
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session?.delegate = self;
            session?.activateSession()
        }
        
        
        
        return true
    }
    
    func launchLandingScreen () {
        let vc = LandingViewController(nibName: "LandingViewController", bundle: nil)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.navigationBarHidden = true
        self.window?.rootViewController = nvc
    }
    
    func launchLoginScreen () {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.window?.rootViewController = vc
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
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
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        self.pushToken = tokenString
        print("device did registered with token \(tokenString)")
        self.updatePushToken()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
        PushNotificationManager.pushManager().handlePushRegistrationFailure(error)
    }
    
    //push notification services delegate
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        PushNotificationManager.pushManager().handlePushReceived(userInfo)
        print("did receive notification \(userInfo)")
    
        if let message = self.saveNotification(userInfo) {
            if application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background {
                self.launchMessagesScreen(message)
            }
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        // 1
        print("Handle Action with identifier \(userInfo)")
        // 2
        self.launchMessageDetailsSceen(userInfo)
        completionHandler()
    }
    
    
    func launchMessageDetailsSceen (userInfo: [NSObject : AnyObject]) {
        if let message = saveNotification(userInfo) {
            if let navVC = window?.rootViewController as? UINavigationController {
                let vc = MessageDetailsViewController(nibName: "MessageDetailsViewController", bundle: nil)
                vc.message = message
                navVC.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onPushAccepted(pushManager: PushNotificationManager!, withNotification pushNotification: [NSObject : AnyObject]!, onStart: Bool) {
        print("Push notification accepted: \(pushNotification)");
    }
    
    func launchMessagesScreen(message : Notification) {
        if let navVC = window?.rootViewController as? UINavigationController {
            let vc = MessageDetailsViewController(nibName: "MessageDetailsViewController", bundle: nil)
            vc.message = message
            navVC.pushViewController(vc, animated: true)
        }
    }
    
    func saveUser (user : User) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(user)
        userDefaults().setObject(data, forKey: "user")
        userDefaults().synchronize()
    }
    
    func getUser () -> User? {
        if let data = userDefaults().objectForKey("user") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as?  User
        }
        return  nil
    }
    
    func userDefaults () -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    func updatePushToken () {
        let user = self.getUser()
        if let token = self.pushToken, tokenString = user?.token {
            let completeURL = Constants.TOKEN_UPDATE_URL + "?token=" + tokenString
            let json = ["user_id" : (user?.userID)!, "device_type" : "ios", "dedvice_token" : token]
            NetworkIO().post(completeURL, json: json) { (data, response, error) in
                if error != nil {
                    print("failed to update token to server, \(error)")
                }else {
                    print("Success when update token to server")
                }
            }
        }
    }
    
    func saveNotification (dictionary : NSDictionary) -> Notification?{

        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.NotificationListUpdate, object: nil)
        let manager = DataManager.sharedInstance()
        if let notif = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: manager.managedObjectContext) as? Notification {
            notif.from = dictionary["from"] as? String
            notif.msg = dictionary["message"] as? String
            notif.notifId = dictionary["id"] as? String
            notif.timeinterval = NSDate().timeIntervalSince1970
            manager.saveContext()
            return notif
        }
        return nil
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if userDefaults().objectForKey(Constants.USER_LOGGED_IN_KEY) as? NSNumber == true {
        
            let msg = message["message"] as? String
            if msg == "Notifications" {
                var json = [NSDictionary]()
                let notifications = DataManager.sharedInstance().getAllNotifications()
                for nt in notifications {
                    json.append(self.getJSON(nt))
                }
                replyHandler(["notifications" : json])
            }else if msg == "assistance" {
                self.callAssistance(replyHandler)
            }else if msg ==  "saveNotification" {
                if let notif = message["notification"] as? [NSObject : AnyObject] {
                    self.saveNotification(notif)
                }
            }
        } else {
            replyHandler(["message" : "Authorization Failed", "code" : 401])
        }
    }
    
    func getJSON (notif : Notification) -> NSDictionary {
        var timeAgo : String?
        if let time = notif.timeinterval {
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(time))
            timeAgo = date.timeAgo
        }
        let json : NSDictionary = ["from": notif.from ?? "", "message": notif.msg ?? "", "time" : timeAgo ?? "", "id" : notif.notifId ?? ""]
        return json
    }

    
    //WARNING: Load somedata here 
    func loadData () {
        let data = ["from" : "Balram", "message":"This is Balram this side. Hope everything is good there", "id" : 1234]
        self.saveNotification(data)

        let data1 = ["from" : "Vijay", "message":"This is Vijay this side. We'll have a get togather soon at Santa Clara town hall.", "id" : 12345]
        self.saveNotification(data1)

        let dat2 = ["from" : "Nandan", "message":"Hey, where you have being all the time? Call me back ASAP", "id" : 123456]
        self.saveNotification(dat2)
    }
    
    func callAssistance (replyHandler: ([String : AnyObject]) -> Void) {
        var json : NSMutableDictionary = [:]
        if let location = self.location {
            json = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude]
        }
        if let user = self.getUser() {
            json.addEntriesFromDictionary(["user_id" : user.userID ?? 0])
            var url = Constants.ASSISTANCE_URL + "?" + "token="
            url += user.token ?? ""
            NetworkIO().post(url, json: json) { (data, response, error) in
                if let _ = error {
                    replyHandler(["message" : "Error", "code" : 500])
                } else {
                    if let httpResponse = response as? NSHTTPURLResponse {
                        let code = httpResponse.statusCode
                        if code == 200 {
                            replyHandler(["message" : "Success", "code" : code])
                        } else if code == 400 || code == 404 {
                            replyHandler(["message" : "Failure",  "code" : code])
                        }
                    }
                }
            }
            
        }

    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSLog("App did receive local notification")
    }
}

