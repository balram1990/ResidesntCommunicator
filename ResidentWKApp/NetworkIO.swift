//
//  NetworkIO.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

class ErrorCodes {
    static let NO_NETWORK = -1
    static let REQUEST_TIMEOUT = -2
    static let AUTH_ERROR = -3
    static let REQUEST_ERROR = -4
    static let SERVER_ERROR = -5
}

class NetworkIO: BaseIO {
    
    func get(url: String, callback: (NSData?, NSURLResponse?, NSError?) -> Void) {
        doService("GET", url: url, body: nil, completionHandler: callback)
    }
    
    func post(url: String, json: NSDictionary?, callback: (NSData?, NSURLResponse?, NSError?) -> Void) {
        doService("POST", url: url, body: json, completionHandler: callback)
    }
    
    func update(url: String, json: NSDictionary?, callback: (NSData?, NSURLResponse?, NSError?) -> Void) {
        doService("PUT", url: url, body: json, completionHandler: callback)
    }
    
    func delete(url: String, json: NSDictionary?, callback: (NSData?, NSURLResponse?, NSError?) -> Void) {
        doService("DELETE", url: url, body: json, completionHandler: callback)
    }
    
    private func doService(method : String, url : String, body : NSDictionary?, completionHandler :  (NSData?, NSURLResponse?, NSError?) -> Void) {
        
        let fullURL = NSURL(string: Constants.BASE_URL + url)
        print("complete url \(fullURL)")
        let request = NSMutableURLRequest(URL: fullURL!)
        request.HTTPMethod = method
        
        //Add Any Header value here, like Authorization
        //request.addValue("", forHTTPHeaderField: "")
        
        if  let _ = body {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var jsonData: NSData? = nil
            do  {
                jsonData = try NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions.init(rawValue: 0))
            } catch {
               print("Something went wrong while parsing JSON")
            }
            request.HTTPBody = jsonData
        }
        //create session
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            dispatch_async(dispatch_get_main_queue(), { 
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            completionHandler(data, response, error)
        })
        
        //intitilze session
        task.resume()
    }
}
