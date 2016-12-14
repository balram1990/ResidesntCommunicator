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
    
    var messageAfterLogin : [AnyHashable: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewContainer = scrollView
        self.usernameTextField.layer.cornerRadius = 5.0
        self.usernameTextField.layer.borderWidth = 1
        let frame = CGRect(x: 0, y: 0, width: 10, height: self.usernameTextField.frame.size.height)
        let leftView1 = UIView(frame:  frame)
        self.usernameTextField.leftView = leftView1
        self.usernameTextField.leftViewMode = .always
        self.usernameTextField.addTarget(self, action: #selector(textChanged), for: UIControlEvents.editingChanged)
        
        self.passwordTextField.layer.cornerRadius = 5.0
        self.passwordTextField.layer.borderWidth = 1
        let leftView2 = UIView(frame:  frame)
        passwordTextField.leftView = leftView2
        self.passwordTextField.leftViewMode = .always
        self.passwordTextField.addTarget(self, action: #selector(textChanged), for: UIControlEvents.editingChanged)

        self.loginButton.layer.cornerRadius = 5.0
        self.loginButton.disable()
        
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            let user = appdelegate.getUser()
            var username : String? = nil
            if user?.loginType == "email" {
                username = user?.email
            }else {
                username = user?.username
            }
            self.usernameTextField.text = username
            self.passwordTextField.text = user?.password
            
            if let _ =  user?.username, let _ = user?.password {
                self.loginButton.enable()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = self.messageAfterLogin {
            self.showAlertForLatestMessage()
        }
    }
    
    func showAlertForLatestMessage () {
        let okayAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        let vc = UIAlertController(title: "Alert!!", message: "Please login to see message", preferredStyle: .alert)
        vc.addAction(okayAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func textChanged (){
        if !self.usernameTextField.containsNothing() && !self.passwordTextField.containsNothing() {
            self.loginButton.enable()
        } else {
            self.loginButton.disable()
        }
    }

    @IBAction func login(_ sender: UIButton) {
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
                    
                    self.passwordTextField.text = nil
                    self.loginButton.isEnabled = false
                    
                    if error?.code == 404 {
                        self.showAlert("Error!!", msg: "Username or password entered are wrong, please try again.", dismissBtnTitle: "Ok")
                        self.passwordTextField.text = nil
                        self.loginButton.isEnabled = false
                    }else {
                        self.handleError(error!)
                    }
                } else {
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 404 {
                            
                        }else if httpResponse.statusCode == 200 {
                            if let userData = data {
                                print("Login response \(response)")
                                UserDefaults.standard.set(true, forKey: Constants.USER_LOGGED_IN_KEY)
                                let user = User()
                                user.parseJson(userData)
                                user.loginType = key
                                user.password = self.passwordTextField.text
                                let delegate = UIApplication.shared.delegate as? AppDelegate
                                delegate?.saveUser(user: user)
                                delegate?.updatePushToken()
                                delegate?.locationManager?.startLocationUpdate()
                                if let _ = self.messageAfterLogin {
                                    delegate?.launchMessageDetailsAfterLogin(messageInfo: self.messageAfterLogin! as [NSObject : AnyObject]?)
                                }else {
                                    delegate?.launchLandingScreen()
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.usernameTextField {
            textField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
        } else {
            self.passwordTextField.resignFirstResponder()
        }
        return true
    }
}
