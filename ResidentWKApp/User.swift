//
//  User.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 02/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

class User: NSObject, NSCoding {

    var token : String?
    var userID : Int?
    var username : String?
    var niceName : String?
    var email : String?
    var url : String?
    var displayName : String?
    var firstName : String?
    var lastName : String?
    var userDescription : String?
    var nickName : String?
    var loginType : String?
    var password : String?
    
    func parseJson (_ json : NSDictionary) {
        
        self.token = getString(json, key: "user_token")
        self.userID = getInt(json, key: "id")
        self.username = getString(json, key: "username")
        self.niceName = getString(json, key: "nicename")
        self.email = getString(json, key: "email")
        self.url = getString(json, key: "url")
        self.displayName = getString(json, key: "displayname")
        self.firstName = getString(json, key: "firstname")
        self.lastName = getString(json, key: "lastname")
        self.nickName = getString(json, key: "nickname")
        self.userDescription = getString(json, key: "description")
        
    }
    
    func getString(_ object: NSDictionary?, key: String) -> String? {
        return object?[key as NSString] as? String
    }
    
    func getInt(_ object: NSDictionary?, key: String) -> Int {
        let val = object?[key as NSString] as? Int
        if nil == val {
            return 0
        }
        return val!
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        let atoken = aDecoder.decodeObject(forKey: "token") as? String
        let anID =  aDecoder.decodeObject(forKey: "id") as? Int
        let aurl = aDecoder.decodeObject(forKey: "url") as? String
        let ausername = aDecoder.decodeObject(forKey: "username") as? String
        let aniceName = aDecoder.decodeObject(forKey: "nicename") as? String
        let anemail = aDecoder.decodeObject(forKey: "email") as? String
        let adisplayName = aDecoder.decodeObject(forKey: "displayname") as? String
        let afirstName = aDecoder.decodeObject(forKey: "firstname") as? String
        let alastName = aDecoder.decodeObject(forKey: "lastname") as? String
        let anickName = aDecoder.decodeObject(forKey: "nickname") as? String
        let auserDescription = aDecoder.decodeObject(forKey: "description") as? String
        let currentLoginType = aDecoder.decodeObject(forKey: "loginType") as? String
        let apassword = aDecoder.decodeObject(forKey: "password") as? String
        
        self.init()
        self.token = atoken
        self.userID = anID
        self.url = aurl
        self.displayName = adisplayName
        self.nickName = anickName
        self.niceName = aniceName
        self.email = anemail
        self.firstName = afirstName
        self.lastName = alastName
        self.userDescription =  auserDescription
        self.username = ausername
        self.loginType = currentLoginType
        self.password = apassword
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.userID, forKey: "id")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.niceName, forKey: "nicename")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.displayName, forKey: "displayname")
        aCoder.encode(self.firstName, forKey: "firstname")
        aCoder.encode(self.lastName, forKey: "lastname")
        aCoder.encode(self.nickName, forKey: "nickname")
        aCoder.encode(self.userDescription, forKey: "description")
        aCoder.encode(self.loginType, forKey:  "loginType")
        aCoder.encode(self.password, forKey: "password")
    }
}
