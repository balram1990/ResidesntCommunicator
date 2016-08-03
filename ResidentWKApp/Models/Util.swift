//
//  Util.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 03/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    class func createJSONFromData(data: NSData?) -> NSDictionary? {
        var json: NSDictionary? = nil
        if let _ = data {
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
            } catch {
                json = nil
            }
        }
        return json
    }

    
}


extension UIViewController {
    func runOnUIThread(block: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    func showAlert(title: String?, msg: String?, positiveTitle: String?, negativeTitle: String?, positiveHandler: (() -> Void)? = nil, negativeHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        let positiveAction = UIAlertAction(title: positiveTitle, style: UIAlertActionStyle.Default, handler: { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            if let _ = positiveHandler {
                positiveHandler!()
            }
        })
        alert.addAction(positiveAction)
        
        let negativeAction = UIAlertAction(title: negativeTitle, style: UIAlertActionStyle.Cancel, handler: { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            if let _ = negativeHandler {
                negativeHandler!()
            }
        })
        alert.addAction(negativeAction)
        
        
        self.presentViewController(alert, animated: true, completion:nil)
    }
    
    func showAlert(title: String?, msg: String?, dismissBtnTitle: String?, dismissHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        let positiveAction = UIAlertAction(title: dismissBtnTitle, style: UIAlertActionStyle.Default, handler: { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            if let _ = dismissHandler {
                dismissHandler!()
            }
        })
        alert.addAction(positiveAction)
        
        self.presentViewController(alert, animated: true, completion:nil)
    }

}

extension UITextField {
    func containsEmail () -> Bool {
        if let text = self.text {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluateWithObject(text)
        } else {
            return false
        }
    }
    
    func containsNothing () -> Bool {
        return (self.text == nil || self.text == "")
    }
}

extension UIButton {
    
    var PrimaryColor : UIColor {
        return UIColor(colorLiteralRed: (28.0/255.0), green: (163.0/255.0), blue: (229.0/255), alpha: 1.0)
    }
    
    var DisabledColor : UIColor {
        return UIColor(colorLiteralRed: (28.0/255.0), green: (163.0/255.0), blue: (229.0/255), alpha: 0.5)
    }
    
    
    func enable() {
        self.backgroundColor = self.PrimaryColor
        self.enabled = true
    }
    
    func disable() {
        self.backgroundColor = self.DisabledColor
        self.enabled = false
    }
}

