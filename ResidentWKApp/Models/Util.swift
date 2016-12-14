//
//  Util.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 03/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    class func createJSONFromData(_ data: Data?) -> NSDictionary? {
        var json: NSDictionary? = nil
        if let _ = data {
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary
            } catch {
                json = nil
            }
        }
        return json
    }
    
    class func dateFromString (_ dateString : String?) -> Date {
        let dFormatter = DateFormatter()
        dFormatter.timeZone = TimeZone(identifier: "UTC")
        dFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        if let date = dFormatter.date(from: dateString ?? "") {
            return date
        }else {
            return Date()
        }
    }
}


extension UIViewController {
    func runOnUIThread(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: block)
    }
    
    func showAlert(_ title: String?, msg: String?, positiveTitle: String?, negativeTitle: String?, positiveHandler: (() -> Void)? = nil, negativeHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        let positiveAction = UIAlertAction(title: positiveTitle, style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            if let _ = positiveHandler {
                positiveHandler!()
            }
        })
        alert.addAction(positiveAction)
        
        let negativeAction = UIAlertAction(title: negativeTitle, style: UIAlertActionStyle.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            if let _ = negativeHandler {
                negativeHandler!()
            }
        })
        alert.addAction(negativeAction)
        
        
        self.present(alert, animated: true, completion:nil)
    }
    
    func showAlert(_ title: String?, msg: String?, dismissBtnTitle: String?, dismissHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        let positiveAction = UIAlertAction(title: dismissBtnTitle, style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            if let _ = dismissHandler {
                dismissHandler!()
            }
        })
        alert.addAction(positiveAction)
        
        self.present(alert, animated: true, completion:nil)
    }

    func handleError (_ error : NSError) {
        
        self.runOnUIThread {
            let errorCode = error.code
            switch errorCode {
            case 400, 404:
                self.showAlert("Error", msg: "Something went wrong. Please try again", dismissBtnTitle: "Dismiss")
            case 401:
                self.showAlert("Oops!!", msg: "Your session is expired. Please login again.", dismissBtnTitle: "Ok", dismissHandler: {
                    if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                        appdelegate.launchLoginScreen(userInfo: nil)
                    }
                })
            default:
                break
            }

        }
    }
}

extension UITextField {
    func containsEmail () -> Bool {
        if let text = self.text {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: text)
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
        self.isEnabled = true
    }
    
    func disable() {
        self.backgroundColor = self.DisabledColor
        self.isEnabled = false
    }
}

extension UIDevice {
    
    func isPhone4CategoryDevice () -> Bool {
        let height = UIScreen.main.bounds.size.height
        return (height == 480 || height == 568)
    }
}

extension Date {
    
    func timeAgo () -> String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            if components.year! < 2 {
                return NSDateTimeAgoLocalizedStrings("Last year")
            } else {
                return stringFromFormat("%%d %@years ago", withValue: components.year!)
            }
        }
        
        if components.month! > 0 {
            if components.month! < 2 {
                return NSDateTimeAgoLocalizedStrings("Last Month")
            } else {
                return stringFromFormat("%%d %@months ago", withValue: components.month!)
            }
        }
        
        // TODO: localize for other calanders
        if components.day! >= 7 {
            let week = components.day!/7
            if week < 2 {
                return NSDateTimeAgoLocalizedStrings("Last week")
            } else {
                return stringFromFormat("%%d %@weeks ago", withValue: week)
            }
        }
        
        if components.day! > 0 {
            if components.day! < 2 {
                return NSDateTimeAgoLocalizedStrings("Yesterday")
            } else  {
                return stringFromFormat("%%d %@days ago", withValue: components.day!)
            }
        }
        
        if components.hour! > 0 {
            if components.hour! < 2 {
                return NSDateTimeAgoLocalizedStrings("An hour ago")
            } else  {
                return stringFromFormat("%%d %@hours ago", withValue: components.hour!)
            }
        }
        
        if components.minute! > 0 {
            if components.minute! < 2 {
                return NSDateTimeAgoLocalizedStrings("A minute ago")
            } else {
                return stringFromFormat("%%d %@minutes ago", withValue: components.minute!)
            }
        }
        
        if components.second! > 0 {
            if components.second! < 5 {
                return NSDateTimeAgoLocalizedStrings("Just Now")
            } else {
                return stringFromFormat("%%d %@seconds ago", withValue: components.second!)
            }
        }
        
        return ""
    }
    
    fileprivate func dateComponents() -> DateComponents {
        let calander = Calendar.current
        return (calander as NSCalendar).components([.second, .minute, .hour, .day, .month, .year], from: self, to: Date(), options: [])
    }
    
    fileprivate func stringFromFormat(_ format: String, withValue value: Int) -> String {
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
        return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
    }
    
    fileprivate func getLocaleFormatUnderscoresWithValue(_ value: Double) -> String {
        guard let localeCode = Locale.preferredLanguages.first else {
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

func NSDateTimeAgoLocalizedStrings(_ key: String) -> String {
    
    return NSLocalizedString(key, comment: "")
}


