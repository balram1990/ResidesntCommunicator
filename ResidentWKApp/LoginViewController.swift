//
//  LoginViewController.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 02/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//


class LoginViewController: KeyboardViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewContainer = scrollView
        self.usernameTextField.layer.cornerRadius = 5.0
        self.usernameTextField.layer.borderWidth = 1
        let frame = CGRectMake(0, 0, 10, self.usernameTextField.frame.size.height)
        let leftView1 = UIView(frame:  frame)
        self.usernameTextField.leftView = leftView1
        self.usernameTextField.leftViewMode = .Always
        self.usernameTextField.addTarget(self, action: #selector(textChanged), forControlEvents: UIControlEvents.EditingChanged)
        
        self.passwordTextField.layer.cornerRadius = 5.0
        self.passwordTextField.layer.borderWidth = 1
        let leftView2 = UIView(frame:  frame)
        passwordTextField.leftView = leftView2
        self.passwordTextField.leftViewMode = .Always
        self.passwordTextField.addTarget(self, action: #selector(textChanged), forControlEvents: UIControlEvents.EditingChanged)

        self.loginButton.layer.cornerRadius = 5.0
        self.loginButton.disable()
    }
    
    func textChanged (){
        if !self.usernameTextField.containsNothing() && !self.passwordTextField.containsNothing() {
            self.loginButton.enable()
        } else {
            self.loginButton.disable()
        }
    }

    @IBAction func login(sender: UIButton) {
        self.loginButton.disable()
        var key : String!
        if usernameTextField.containsEmail() {
            key = "email"
        }else {
            key = "username"
        }
        let json : NSDictionary? = [key : self.usernameTextField.text!, "password" : self.passwordTextField.text!]
        NetworkIO().post(Constants.LOGIN_URL, json: json) { (data, response, error) in
            self.runOnUIThread({
                if let _ = error {
                    self.showAlert("Error!!", msg: error?.localizedDescription, dismissBtnTitle: "Ok")
                    self.passwordTextField.text = nil
                    self.loginButton.enabled = false
                } else {
                    
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 404 {
                            self.showAlert("Error!!", msg: "Username or password entered are wrong, please try again.", dismissBtnTitle: "Ok")
                            self.passwordTextField.text = nil
                            self.loginButton.enabled = false
                        }else if httpResponse.statusCode == 200 {
                            if let userData = Util.createJSONFromData(data) {
                                print("Login response \(response)")
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.USER_LOGGED_IN_KEY)
                                let user = User()
                                user.parseJson(userData)
                                let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
                                delegate?.saveUser(user)
                                delegate?.updatePushToken()
                                delegate?.locationManager?.startLocationUpdate()
                                delegate?.launchLandingScreen()
                            }
                        }
                    }
                }
            })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == self.usernameTextField {
            textField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
        } else {
            self.passwordTextField.resignFirstResponder()
        }
        return true
    }
}
