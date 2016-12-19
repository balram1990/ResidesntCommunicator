//
//  Constants.swift
//  ResidentWKApp
//
//  Created by Balram Singh on 01/08/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//


class Constants {
    static var BASE_URL = "http://aptoseniorcare.com/wp-json/"
    static let LOGIN_URL = "v1/account/login"
    static let TOKEN_UPDATE_URL = "v1/push-service"
    static let LOCATION_UPDATE_URL = "v1/user/location/"//v1/user/location/{user_id}?token={user_token}
    static let ASSISTANCE_URL = "v1/assistance"//?token=<token value>
    static let USER_LOGGED_IN_KEY = "isUserLoggedIn"
    static let MESSAGES_URL = "v1/push-service"
    static let CHECK_LOCATION_URL = "v1/user/sendtime?userid="
    static let LAST_LOCATION_UPDATE_TIME_KEY = ""
    
 
}
