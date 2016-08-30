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
    
    func parseJson (json : NSDictionary) {
        
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
    
    func getString(object: NSDictionary?, key: String) -> String? {
        return object?[key as NSString] as? String
    }
    
    func getInt(object: NSDictionary?, key: String) -> Int {
        let val = object?[key as NSString] as? Int
        if nil == val {
            return 0
        }
        return val!
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        let atoken = aDecoder.decodeObjectForKey("token") as? String
        let anID =  aDecoder.decodeObjectForKey("id") as? Int
        let aurl = aDecoder.decodeObjectForKey("url") as? String
        let ausername = aDecoder.decodeObjectForKey("username") as? String
        let aniceName = aDecoder.decodeObjectForKey("nicename") as? String
        let anemail = aDecoder.decodeObjectForKey("email") as? String
        let adisplayName = aDecoder.decodeObjectForKey("displayname") as? String
        let afirstName = aDecoder.decodeObjectForKey("firstname") as? String
        let alastName = aDecoder.decodeObjectForKey("lastname") as? String
        let anickName = aDecoder.decodeObjectForKey("nickname") as? String
        let auserDescription = aDecoder.decodeObjectForKey("description") as? String
        let currentLoginType = aDecoder.decodeObjectForKey("loginType") as? String
        let apassword = aDecoder.decodeObjectForKey("password") as? String
        
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
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.token, forKey: "token")
        aCoder.encodeObject(self.userID, forKey: "id")
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.niceName, forKey: "nicename")
        aCoder.encodeObject(self.email, forKey: "email")
        aCoder.encodeObject(self.url, forKey: "url")
        aCoder.encodeObject(self.displayName, forKey: "displayname")
        aCoder.encodeObject(self.firstName, forKey: "firstname")
        aCoder.encodeObject(self.lastName, forKey: "lastname")
        aCoder.encodeObject(self.nickName, forKey: "nickname")
        aCoder.encodeObject(self.userDescription, forKey: "description")
        aCoder.encodeObject(self.loginType, forKey:  "loginType")
        aCoder.encodeObject(self.password, forKey: "password")
    }
}
