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
                        self.showAlert("Error!!", msg: error?.localizedDescription, dismissBtnTitle: "Dismiss", dismissHandler: nil)
                    } else {
                        if let httpResponse = response as? NSHTTPURLResponse {
                            let code = httpResponse.statusCode
                            if code == 200 {
                                self.showAlert("Success", msg: "Concerned people have been informed. They will contact you soon.", dismissBtnTitle: "Dismiss", dismissHandler: nil)
                            } else if code == 400 || code == 404 {
                                self.showAlert("Error!!", msg: "Something went wrong, please try again.", dismissBtnTitle: "Dismiss", dismissHandler: nil)
                            }
                        }
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
        let appdelegate =  UIApplication.sharedApplication().delegate as? AppDelegate
        appdelegate?.launchLoginScreen()
        
    }
}
