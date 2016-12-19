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
        if UIDevice.current.isPhone4CategoryDevice() {
            buttonHeightConstraint.constant = 100
        } else {
            buttonHeightConstraint.constant = 150
        }
    }
    
    @IBAction func callAssistance(_ sender: UIButton) {
        
        //latitude
        //longitude
        //user_id
        //token in url
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        var json : NSMutableDictionary = [:]
        if let location = appdelegate?.location {
            json = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude]
        }else {
            self.showAlert("Oops!!", msg: "Seems like you have not enabled location services for the app. Please enable   the same and try again.", positiveTitle: "Settings", negativeTitle: "Not Now", positiveHandler: {
                    UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                }, negativeHandler: { 
                    
            })
            return
        }
       
        if let user = appdelegate?.getUser() {
            json.addEntries(from: ["user_id" : user.userID ?? 0])
             var url = Constants.ASSISTANCE_URL + "?" + "token="
             url += user.token ?? ""
            self.assistanceBtn.isEnabled = false
            NetworkIO().post(url, json: json) { (data, response, error) in
                self.runOnUIThread({
                    self.assistanceBtn.isEnabled = true
                    if let _ = error {
                        self.handleError(error!)
                        return
                    } else {
                        self.showAlert("Success", msg: "Concerned people have been informed. They will contact you soon.", dismissBtnTitle: "Dismiss", dismissHandler: nil)
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.assitanceCalled = true
                    }
                })
            }

        }
        
    }
    
    @IBAction func showMessages(_ sender: UIButton) {
        let vc = MessagesViewController(nibName: "MessagesViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func logout(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: Constants.USER_LOGGED_IN_KEY)
        let appdelegate =  UIApplication.shared.delegate as? AppDelegate
        appdelegate?.launchLoginScreen(userInfo: nil)
        
    }
}
