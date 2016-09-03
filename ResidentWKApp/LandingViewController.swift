//
//  LandingViewController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 03/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

class LandingViewController: UIViewController {
    
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var assistanceBtn: UIButton!
    @IBOutlet weak var assistanceLabel: UILabel!
    @IBOutlet weak var messagesBtn: UIButton!
    @IBOutlet weak var messagesLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.currentDevice().isPhone4CategoryDevice() {
            buttonHeightConstraint.constant = 100
        } else {
            buttonHeightConstraint.constant = 150
        }
    }
    
    @IBAction func callAssistance(sender: UIButton) {
        
        //latitude
        //longitude
        //user_id
        //token in url
        let appdelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        var json : NSMutableDictionary = [:]
        if let location = appdelegate?.location {
            json = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude]
        }else {
            self.showAlert("Oops!!", msg: "Seems like you have not enabled location services for the app. Please enable   the same and try again.", positiveTitle: "Settings", negativeTitle: "Not Now", positiveHandler: {
                    UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                }, negativeHandler: { 
                    
            })
            return
        }
       
        if let user = appdelegate?.getUser() {
            json.addEntriesFromDictionary(["user_id" : user.userID ?? 0])
             var url = Constants.ASSISTANCE_URL + "?" + "token="
             url += user.token ?? ""
            self.assistanceBtn.enabled = false
            NetworkIO().post(url, json: json) { (data, response, error) in
                self.runOnUIThread({
                    self.assistanceBtn.enabled = true
                    if let _ = error {
                        self.handleError(error!)
                        return
                    } else {
                        self.showAlert("Success", msg: "Concerned people have been informed. They will contact you soon.", dismissBtnTitle: "Dismiss", dismissHandler: nil)
                    }
                })
            }

        }
        
    }
    
    @IBAction func showMessages(sender: UIButton) {
        let vc = MessagesViewController(nibName: "MessagesViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func logout(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: Constants.USER_LOGGED_IN_KEY)
        let appdelegate =  UIApplication.sharedApplication().delegate as? AppDelegate
        appdelegate?.launchLoginScreen(nil)
        
    }
}
