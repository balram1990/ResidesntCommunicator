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

extension UIDevice {
    
    func isPhone4CategoryDevice () -> Bool {
        let height = UIScreen.mainScreen().bounds.size.height
        return (height == 480 || height == 568)
    }
}

extension NSDate {
    
    public var timeAgo: String {
        let components = self.dateComponents()
        
        if components.year > 0 {
            if components.year < 2 {
                return NSDateTimeAgoLocalizedStrings("Last year")
            } else {
                return stringFromFormat("%%d %@years ago", withValue: components.year)
            }
        }
        
        if components.month > 0 {
            if components.month < 2 {
                return NSDateTimeAgoLocalizedStrings("Last Month")
            } else {
                return stringFromFormat("%%d %@months ago", withValue: components.month)
            }
        }
        
        // TODO: localize for other calanders
        if components.day >= 7 {
            let week = components.day/7
            if week < 2 {
                return NSDateTimeAgoLocalizedStrings("Last week")
            } else {
                return stringFromFormat("%%d %@weeks ago", withValue: week)
            }
        }
        
        if components.day > 0 {
            if components.day < 2 {
                return NSDateTimeAgoLocalizedStrings("Yesterday")
            } else  {
                return stringFromFormat("%%d %@days ago", withValue: components.day)
            }
        }
        
        if components.hour > 0 {
            if components.hour < 2 {
                return NSDateTimeAgoLocalizedStrings("An hour ago")
            } else  {
                return stringFromFormat("%%d %@hours ago", withValue: components.hour)
            }
        }
        
        if components.minute > 0 {
            if components.minute < 2 {
                return NSDateTimeAgoLocalizedStrings("A minute ago")
            } else {
                return stringFromFormat("%%d %@minutes ago", withValue: components.minute)
            }
        }
        
        if components.second > 0 {
            if components.second < 5 {
                return NSDateTimeAgoLocalizedStrings("Just Now")
            } else {
                return stringFromFormat("%%d %@seconds ago", withValue: components.second)
            }
        }
        
        return ""
    }
    
    private func dateComponents() -> NSDateComponents {
        let calander = NSCalendar.currentCalendar()
        return calander.components([.Second, .Minute, .Hour, .Day, .Month, .Year], fromDate: self, toDate: NSDate(), options: [])
    }
    
    private func stringFromFormat(format: String, withValue value: Int) -> String {
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
        return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
    }
    
    private func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
        guard let localeCode = NSLocale.preferredLanguages().first else {
            return ""
        }
        
        // Russian (ru) and Ukrainian (uk)
        if localeCode == "ru" || localeCode == "uk" {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        
        return ""
    }
    
}

func NSDateTimeAgoLocalizedStrings(key: String) -> String {
    
    return NSLocalizedString(key, comment: "")
}


