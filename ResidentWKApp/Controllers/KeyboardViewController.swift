
import UIKit

class KeyboardViewController : UIViewController, UITextFieldDelegate {
    fileprivate var textField: UITextField? = nil
    fileprivate var originalFrame: CGRect? = nil
    var scrollViewContainer : UIScrollView? = nil
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField = textField
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.keyboardShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.keyboardHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(forceEndEditing), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.originalFrame = self.view.frame
        if self.scrollViewContainer != nil {
            let tapGesture  = UITapGestureRecognizer(target: self, action: #selector(forceEndEditing))
            self.scrollViewContainer?.addGestureRecognizer(tapGesture)
        }
    }
    
    func forceEndEditing () {
        if self.scrollViewContainer != nil {
            self.scrollViewContainer?.endEditing(true)
        } else {
            self.view.endEditing(true)
        }
    }
    
    
    func keyboardShown(_ notification: Foundation.Notification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        
        let movementDuration = 0.1;
        
        if let _ = self.textField {
            let  frame = (self.textField?.convert((self.textField?.bounds)!, to: self.view))!
            let originPoint = self.textField?.convert((self.textField?.bounds.origin)!, to: self.view)
            if (originPoint!.y + frame.size.height) > keyboardFrame.origin.y {
                let movement = keyboardFrame.origin.y - originPoint!.y -  100;
                
                UIView.beginAnimations("anim", context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(movementDuration)
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement);
                UIView.commitAnimations();
            } else if let _ = self.originalFrame {
                let movement = (self.originalFrame?.origin.y)! - self.view.frame.origin.y;
                UIView.beginAnimations("anim", context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(movementDuration)
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement);
                UIView.commitAnimations();
            }
        }
    }
    
    func keyboardHidden(_ notification: Foundation.Notification) {
        let movementDuration = 0.1;
        if let _ = self.originalFrame {
            let movement = (self.originalFrame?.origin.y)! - self.view.frame.origin.y;
            UIView.beginAnimations("anim", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(movementDuration)
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement);
            UIView.commitAnimations();
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
