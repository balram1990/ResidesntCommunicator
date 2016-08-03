
import UIKit

class KeyboardViewController : UIViewController, UITextFieldDelegate {
    private var textField: UITextField? = nil
    private var originalFrame: CGRect? = nil
    var scrollViewContainer : UIScrollView? = nil
    func textFieldDidBeginEditing(textField: UITextField) {
        self.textField = textField
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.keyboardShown), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.keyboardHidden), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(forceEndEditing), name: UIApplicationWillResignActiveNotification, object: nil)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        let movementDuration = 0.1;
        
        if let _ = self.textField {
            let  frame = (self.textField?.convertRect((self.textField?.bounds)!, toView: self.view))!
            let originPoint = self.textField?.convertPoint((self.textField?.bounds.origin)!, toView: self.view)
            if (originPoint!.y + frame.size.height) > keyboardFrame.origin.y {
                let movement = keyboardFrame.origin.y - originPoint!.y -  100;
                
                UIView.beginAnimations("anim", context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(movementDuration)
                self.view.frame = CGRectOffset(self.view.frame, 0, movement);
                UIView.commitAnimations();
            } else if let _ = self.originalFrame {
                let movement = (self.originalFrame?.origin.y)! - self.view.frame.origin.y;
                UIView.beginAnimations("anim", context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(movementDuration)
                self.view.frame = CGRectOffset(self.view.frame, 0, movement);
                UIView.commitAnimations();
            }
        }
    }
    
    func keyboardHidden(notification: NSNotification) {
        let movementDuration = 0.1;
        if let _ = self.originalFrame {
            let movement = (self.originalFrame?.origin.y)! - self.view.frame.origin.y;
            UIView.beginAnimations("anim", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(movementDuration)
            self.view.frame = CGRectOffset(self.view.frame, 0, movement);
            UIView.commitAnimations();
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
