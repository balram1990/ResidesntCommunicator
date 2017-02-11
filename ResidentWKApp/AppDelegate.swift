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
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate, WCSessionDelegate, UNUserNotificationCenterDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }


    var window: UIWindow?
    var locationManager : LocationManager?
    var location : CLLocation?
    var pushToken : String?
    static let NotificationListUpdate = "NotificationListUpdate"
    var session : WCSession?
    var assitanceCalled = false
    var assitanceCalledTime : Date?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
                // Override point for customization after application launch.
                //self.loadData()
        NSLog("App Did finish launching with optipns \(launchOptions)")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.isHidden = false
        self.registerForPushNotifications(application: application)
        locationManager = LocationManager()
        locationManager?.startLocationUpdate()
        let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as! [NSObject : AnyObject]?
        if userDefaults().object(forKey: Constants.USER_LOGGED_IN_KEY) as? NSNumber == true {
            self.launchLandingScreen()
        } else {
            if let _ = remoteNotification {
                self.launchLoginScreen(userInfo: remoteNotification!)

            }else {
                self.launchLoginScreen(userInfo: nil)
            }
        }

        if (WCSession.isSupported()) {
            session = WCSession.default()
            session?.delegate = self;
            session?.activate()
        }
        return true

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Push Notification Handling
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                
                if granted == true && error == nil {
                    print("Authorized for push notification")
                    UIApplication.shared.registerForRemoteNotifications()
                }else{
                    NSLog("Unauthorized for push notifications : \(error?.localizedDescription)")
                }
            }
        } else {
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()

        }
    }

    //MARK: Notification registration delegates
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        self.pushToken = tokenString
        NSLog("device did registered with token %@", tokenString)
        self.updatePushToken()
    }
    
    func updatePushToken () {
        let user = self.getUser()
        if let token = self.pushToken, let tokenString = user?.token {
            let completeURL = Constants.TOKEN_UPDATE_URL + "?token=" + tokenString
            let json = ["user_id" : (user?.userID)!, "device_type" : "ios", "device_token" : token, "information" : user?.username ?? ""] as [String : Any]
            NetworkIO().post(completeURL, json: json as NSDictionary?) { (data, response, error) in
                if error != nil {
                    NSLog("failed to update token to server %@", error!.localizedDescription)
                    self.window?.rootViewController?.handleError(error!)
                }else {
                    NSLog("Successfully updated registration token to server")
                }
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Failed to register: %@", error.localizedDescription)
        let vc = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        vc.addAction(action)
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)

    }
    
    //push notification services delegate
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("did receive notification %@", userInfo)
        if application.applicationState == UIApplicationState.inactive {
            self.launchMessageDetailsForMessage(dictionary: userInfo)
            
        }else if application.applicationState == .active {
            self.downlaodMessageContent(userInfo: userInfo as! [String : AnyObject], replyHandler: nil)
            self.handleNotificationInActiveMode(dictionary: userInfo as! [String : AnyObject])
            
        }else {
            //set badge number
            let count = DataManager.sharedInstance().getUnreadNotificaitons().count
            UIApplication.shared.applicationIconBadgeNumber = (count+1)
            //download content and save data
            self.downlaodMessageContent(userInfo: userInfo as! [String : AnyObject], replyHandler: nil)
        }

    }    
    //Screen Handling
    func launchLandingScreen () {
        let vc = LandingViewController(nibName: "LandingViewController", bundle: nil)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = true
        self.window?.rootViewController = nvc
    }
    
    func launchMessageDetailsAfterLogin(messageInfo : [NSObject : AnyObject]? ) {
        self.launchLandingScreen()
        self.launchMessageDetailsForMessage(dictionary: (messageInfo as! [String : AnyObject]?)!)
    }
    
    func launchLoginScreen (userInfo: [NSObject : AnyObject]?) {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        vc.messageAfterLogin = userInfo
        self.window?.rootViewController = vc
        
    }

    
    
    func downlaodMessageContent (userInfo: [String : AnyObject] , replyHandler: (([String : Any]) -> Void)?) {
        NSLog("Starting download of content message userinfo \(userInfo)")
        let user = self.getUser()
        if let tokenString = user?.token, let data = userInfo["aps"] as? NSDictionary, let messageID = data["message_id"] as? String{
            let completeURL = Constants.MESSAGES_URL + "/" + String(user!.userID!) + "/message/" +  String(messageID) + "?token=" + tokenString
            NetworkIO().get(completeURL, callback: { (data, response, error) in
                if let _ = error {
                    NSLog("Something went wrong while fetching content %@", error!.localizedDescription)
                    if let _ = replyHandler {
                        replyHandler!(["notifications" : "" as AnyObject, "code" : error!.code as AnyObject])
                    }
                    return
                }else {
                    //save notfication
                    if let _ = data {
                        self.addNotification(data: data!)
                        if let _ = replyHandler {
                            //get curent notification
                            if let msg = DataManager.sharedInstance().getNotifcationById(messageID) {
                                replyHandler!(["notifications" : self.getJSON(notif: msg), "code" : 200 as AnyObject])
                            }else {
                                replyHandler!(["notifications" : NSDictionary(), "code" : 200 as AnyObject])
                            }
                            
                        }
                    }
                }
            })
        }else {
            if let _ = replyHandler {
                replyHandler!(["notifications" : "" as AnyObject, "code" : 500 as AnyObject])
            }
        }
    }
    
    
    func addNotification (data : NSDictionary)  {
        NSLog("Adding notification to DB %@",data)
        let manager = DataManager.sharedInstance()
        let msgId = data["id"] as! String
        if manager.getNotifcationById(msgId) == nil {
            if let notif = NSEntityDescription.insertNewObject(forEntityName: "Notification", into: manager.managedObjectContext) as? Notification {
                notif.from = data["sender_display_name"] as? String
                notif.msg = data["message"] as? String
                notif.notifId = msgId
                notif.hasContent = true
                let dateString = data["time"] as? String
                notif.timeinterval = Util.dateFromString(dateString).timeIntervalSince1970 as NSNumber?
                manager.saveContext()
            }
        }
    }
    
    func launchMessageDetailsForMessage(dictionary :  [AnyHashable : Any]?) {
        
        if let navVC = window?.rootViewController as? UINavigationController, let dictData = dictionary as? [String : AnyObject] {
            let vc = MessageDetailsViewController(nibName: "MessageDetailsViewController", bundle: nil)
            if let _ = dictionary, let data = dictData["aps"] as? NSDictionary , let messageId = data["message_id"] as? String {
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
    
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        NSLog("Push notification accepted: \(pushNotification)");
    }
    
    func saveUser (user : User) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        userDefaults().set(data, forKey: "user")
        userDefaults().synchronize()
    }
    
    func getUser () -> User? {
        if let data = userDefaults().object(forKey: "user") as? NSData {
            return NSKeyedUnarchiver.unarchiveObject(with: data as Data) as?  User
        }
        return  nil
    }
    
    func userDefaults () -> UserDefaults {
        return UserDefaults.standard
    }
    
    func saveNotification (dictionary : NSDictionary) -> Notification?{

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppDelegate.NotificationListUpdate), object: nil)
        let manager = DataManager.sharedInstance()
        if let data = dictionary["aps"] as? NSDictionary {
               if let notif = NSEntityDescription.insertNewObject(forEntityName: "Notification", into: manager.managedObjectContext) as? Notification {
                
                notif.from = data["sender_display_name"] as? String
                notif.msg = data["message"] as? String
                notif.notifId = data["message_id"] as? String
                notif.timeinterval = NSDate().timeIntervalSince1970 as NSNumber?
                manager.saveContext()
                return notif
            }
        }
        return nil
    }

    func getJSON (notif : Notification) -> NSDictionary {
        var timeAgo : String?
        if let time = notif.timeinterval {
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            timeAgo = date.timeAgo()
        }
        let json : NSDictionary = ["from": notif.from ?? "", "message": notif.msg ?? "", "time" : timeAgo ?? "", "id" : notif.notifId ?? ""]
        return json
    }

    func handleNotificationInActiveMode (dictionary : [String : AnyObject]) {
        
        if let data = dictionary["aps"] as? NSDictionary , let messageId = data["message_id"] as? String {
            let message = data["alert"] as? String
            let appDisplayName =  Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            let banner = Banner(title: appDisplayName, subtitle: message, image: nil, backgroundColor: UIColor.black)
            banner.textColor = UIColor.white
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
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        NSLog("Session did receive message: \(message)")
        if userDefaults().object(forKey: Constants.USER_LOGGED_IN_KEY) as? NSNumber == true {

            let msg = message["message"] as? String
            if msg == "Notifications" {
                var json = [NSDictionary]()
                let notifications = DataManager.sharedInstance().getAllNotifications()
                for nt in notifications {
                    json.append(self.getJSON(notif: nt))
                    if json.count == 10 {
                        break
                    }
                }
                replyHandler(["notifications" : json as AnyObject, "code" : 200 as AnyObject])
            }else if msg == "assistance" {
                self.callAssistance(replyHandler: replyHandler)
            }else if msg ==  "saveNotification" {
                self.downlaodMessageContent(userInfo: message as [String : AnyObject], replyHandler: replyHandler)
            }
        } else {
            replyHandler(["message" : "Authorization Failed" as AnyObject, "code" : 401 as AnyObject])
        }

    }
    
    func callAssistance (replyHandler: @escaping ([String : Any]) -> Void) {
        NSLog("Call Assistance from watch")
        var json : NSMutableDictionary = [:]
        if let location = self.location {
            json = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude]
            if let user = self.getUser() {
                json.addEntries(from: ["user_id" : user.userID ?? 0])
                var url = Constants.ASSISTANCE_URL + "?" + "token="
                url += user.token ?? ""
                NetworkIO().post(url, json: json) { (data, response, error) in
                    if let _ = error {
                        NSLog("App Delegate Error while calling assistance error: \(error!.localizedDescription)")
                        replyHandler(["message" : "Error" as AnyObject, "code" : error!.code as AnyObject])
                    } else {
                        replyHandler(["message" : "Success" as AnyObject, "code" : 200 as AnyObject])
                        self.assitanceCalled = true
                    }
                }
            }else {
                //No login
                replyHandler(["message" : "Failure" as AnyObject,  "code" : 401 as AnyObject])
            }

        }else {
            //location services not available
            replyHandler(["message" : "Failure" as AnyObject,  "code" : 300 as AnyObject])
            
        }
        
    }
}

