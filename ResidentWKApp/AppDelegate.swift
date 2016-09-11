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
import BRYXBanner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var locationManager : LocationManager?
    var location : CLLocation?
    var pushToken : String?
    static let NotificationListUpdate = "NotificationListUpdate"
    var session : WCSession?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //self.loadData()
        NSLog("App Did finish launching with optipns \(launchOptions)")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.hidden = false
        self.registerForPushNotifications(application)
        locationManager = LocationManager()
        locationManager?.startLocationUpdate()
        let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as! [NSObject : AnyObject]?
        if userDefaults().objectForKey(Constants.USER_LOGGED_IN_KEY) as? NSNumber == true {
            self.launchLandingScreen()
        } else {
            if let _ = remoteNotification {
                self.launchLoginScreen(remoteNotification!)
                
            }else {
                self.launchLoginScreen(nil)
            }
        }
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session?.delegate = self;
            session?.activateSession()
        }
        return true
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
    
    //MARK: Push Notification Handling
    func registerForPushNotifications(application: UIApplication) {
        
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }

    //MARK: Notification registration delegates
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        self.pushToken = tokenString
        NSLog("device did registered with token %@", tokenString)
        self.updatePushToken()
    }
    
    func updatePushToken () {
        let user = self.getUser()
        if let token = self.pushToken, tokenString = user?.token {
            let completeURL = Constants.TOKEN_UPDATE_URL + "?token=" + tokenString
            let json = ["user_id" : (user?.userID)!, "device_type" : "ios", "device_token" : token, "information" : user?.username ?? ""]
            NetworkIO().post(completeURL, json: json) { (data, response, error) in
                if error != nil {
                    NSLog("failed to update token to server %@", error!.localizedDescription)
                    self.window?.rootViewController?.handleError(error!)
                }else {
                    NSLog("Successfully updated registration token to server")
                }
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("Failed to register: %@", error.localizedDescription)
    }
    
    //push notification services delegate
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        NSLog("did receive notification %@", userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            self.launchMessageDetailsForMessage(userInfo)
            completionHandler(UIBackgroundFetchResult.NewData)
        }else if application.applicationState == .Active {
            self.downlaodMessageContent(userInfo, completionHandler: completionHandler, replyHandler: nil)
            self.handleNotificationInActiveMode(userInfo)
            completionHandler(UIBackgroundFetchResult.NewData)
        }else {
            //set badge number
            let count = DataManager.sharedInstance().getUnreadNotificaitons().count
            UIApplication.sharedApplication().applicationIconBadgeNumber = (count+1)
            //download content and save data
            self.downlaodMessageContent(userInfo, completionHandler: completionHandler, replyHandler: nil)
        }
    }
    
    //Screen Handling
    func launchLandingScreen () {
        let vc = LandingViewController(nibName: "LandingViewController", bundle: nil)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.navigationBarHidden = true
        self.window?.rootViewController = nvc
    }
    
    func launchMessageDetailsAfterLogin(messageInfo : [NSObject : AnyObject]? ) {
        self.launchLandingScreen()
        self.launchMessageDetailsForMessage(messageInfo)
    }
    
    func launchLoginScreen (userInfo: [NSObject : AnyObject]?) {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        vc.messageAfterLogin = userInfo
        self.window?.rootViewController = vc
        
    }

    
    
    func downlaodMessageContent (userInfo: [NSObject : AnyObject], completionHandler: ((UIBackgroundFetchResult) -> Void)? , replyHandler: ([String : AnyObject] -> Void)?) {
        NSLog("Starting download of content message userinfo \(userInfo)")
        let user = self.getUser()
        if let tokenString = user?.token, data = userInfo["aps"] as? NSDictionary, messageID = data["message_id"] as? String{
            let completeURL = Constants.MESSAGES_URL + "/" + String(user!.userID!) + "/message/" +  String(messageID) + "?token=" + tokenString
            NetworkIO().get(completeURL, callback: { (data, response, error) in
                if let _ = error {
                    NSLog("Something went wrong while fetching content %@", error!.localizedDescription)
                    if let _ = completionHandler {
                        completionHandler!(UIBackgroundFetchResult.NewData)
                    }else if let _ = replyHandler {
                        replyHandler!(["notifications" : "", "code" : error!.code])
                    }
                    return
                }else {
                    //save notfication
                    if let _ = data {
                        self.addNotification(data!)
                        if let _ = completionHandler {
                            completionHandler!(UIBackgroundFetchResult.NewData)
                        }else if let _ = replyHandler {
                            //get curent notification
                            if let msg = DataManager.sharedInstance().getNotifcationById(messageID) {
                                replyHandler!(["notifications" : self.getJSON(msg), "code" : 200])
                            }else {
                                replyHandler!(["notifications" : [:], "code" : 200])
                            }
                            
                        }
                    }
                }
            })
        }else {
            if let _ = completionHandler {
                completionHandler!(UIBackgroundFetchResult.NewData)
            }else if let _ = replyHandler {
                replyHandler!(["notifications" : "", "code" : 500])
            }
        }
    }
    
    
    func addNotification (data : NSDictionary)  {
        NSLog("Adding notification to DB %@",data)
        let manager = DataManager.sharedInstance()
        let msgId = data["id"] as! String
        if manager.getNotifcationById(msgId) == nil {
            if let notif = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: manager.managedObjectContext) as? Notification {
                notif.from = data["sender_display_name"] as? String
                notif.msg = data["message"] as? String
                notif.notifId = msgId
                notif.hasContent = true
                let dateString = data["time"] as? String
                notif.timeinterval = Util.dateFromString(dateString).timeIntervalSince1970
                manager.saveContext()
            }
        }
    }
    
    func launchMessageDetailsForMessage(dictionary : [NSObject : AnyObject]?) {
        
        if let navVC = window?.rootViewController as? UINavigationController {
            let vc = MessageDetailsViewController(nibName: "MessageDetailsViewController", bundle: nil)
            if let _ = dictionary, data = dictionary!["aps"] as? NSDictionary , messageId = data["message_id"] as? String {
                vc.handleMessage(messageId)
            }
            navVC.pushViewController(vc, animated: true)
        }else {
            if let loginVC = window?.rootViewController as? LoginViewController {
                loginVC.messageAfterLogin = dictionary
                loginVC.showAlertForLatestMessage()
            }
        }
    }
    
    func onPushAccepted(pushManager: PushNotificationManager!, withNotification pushNotification: [NSObject : AnyObject]!, onStart: Bool) {
        NSLog("Push notification accepted: \(pushNotification)");
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
    
    func saveNotification (dictionary : NSDictionary) -> Notification?{

        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.NotificationListUpdate, object: nil)
        let manager = DataManager.sharedInstance()
        if let data = dictionary["aps"] as? NSDictionary {
               if let notif = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: manager.managedObjectContext) as? Notification {
                
                notif.from = data["sender_display_name"] as? String
                notif.msg = data["message"] as? String
                notif.notifId = data["message_id"] as? String
                notif.timeinterval = NSDate().timeIntervalSince1970
                manager.saveContext()
                return notif
            }
        }
        return nil
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

    func handleNotificationInActiveMode (dictionary : [NSObject : AnyObject]) {
        
        if let data = dictionary["aps"] as? NSDictionary , messageId = data["message_id"] as? String {
            let message = data["alert"] as? String
            let appDisplayName =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as? String
            let banner = Banner(title: appDisplayName, subtitle: message, image: nil, backgroundColor: UIColor.blackColor())
            banner.textColor = UIColor.whiteColor()
            let completionBlock = {
                    if let navVC = self.window?.rootViewController as? UINavigationController {
                        if let messageDetailsVC = navVC.topViewController as? MessageDetailsViewController {
                            messageDetailsVC.handleMessage(messageId)
                        }else {
                            let vc = MessageDetailsViewController(nibName: "MessageDetailsViewController", bundle: nil)
                            vc.handleMessage(messageId)
                            navVC.pushViewController(vc, animated: true)
                        }
                }
            }
            banner.didTapBlock = completionBlock
            banner.show()
        }

    }
    
    
    //MARK: Watch handling
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        NSLog("Session did receive message: \(message)")
        if userDefaults().objectForKey(Constants.USER_LOGGED_IN_KEY) as? NSNumber == true {
            
            let msg = message["message"] as? String
            if msg == "Notifications" {
                var json = [NSDictionary]()
                let notifications = DataManager.sharedInstance().getAllNotifications()
                for nt in notifications {
                    json.append(self.getJSON(nt))
                    if json.count == 10 {
                        break
                    }
                }
                replyHandler(["notifications" : json, "code" : 200])
            }else if msg == "assistance" {
                self.callAssistance(replyHandler)
            }else if msg ==  "saveNotification" {
                self.downlaodMessageContent(message, completionHandler: nil, replyHandler: replyHandler)
            }
        } else {
            replyHandler(["message" : "Authorization Failed", "code" : 401])
        }
    }
    
    func callAssistance (replyHandler: ([String : AnyObject]) -> Void) {
        NSLog("Call Assistance from watch")
        var json : NSMutableDictionary = [:]
        if let location = self.location {
            json = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude]
            if let user = self.getUser() {
                json.addEntriesFromDictionary(["user_id" : user.userID ?? 0])
                var url = Constants.ASSISTANCE_URL + "?" + "token="
                url += user.token ?? ""
                NetworkIO().post(url, json: json) { (data, response, error) in
                    if let _ = error {
                        NSLog("App Delegate Error while calling assistance error: \(error!.localizedDescription)")
                        replyHandler(["message" : "Error", "code" : error!.code])
                    } else {
                        replyHandler(["message" : "Success", "code" : 200])
                    }
                }
            }else {
                //No login
                replyHandler(["message" : "Failure",  "code" : 401])
            }

        }else {
            //location services not available
            replyHandler(["message" : "Failure",  "code" : 300])
            
        }
        
    }
}

