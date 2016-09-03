//
//  NetworkIO.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit
import Foundation

class ErrorCodes {
    static let NO_NETWORK = -1
    static let REQUEST_TIMEOUT = -2
    static let AUTH_ERROR = -3
    static let REQUEST_ERROR = -4
    static let SERVER_ERROR = -5
}

class NetworkIO: BaseIO {
    
    func get(url: String, callback: (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        doService("GET", url: url, body: nil, completionHandler: callback)
    }
    
    func post(url: String, json: NSDictionary?, callback: (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        doService("POST", url: url, body: json, completionHandler: callback)
    }
    
    func update(url: String, json: NSDictionary?, callback: (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        doService("PUT", url: url, body: json, completionHandler: callback)
    }
    
    func delete(url: String, json: NSDictionary?, callback: (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        doService("DELETE", url: url, body: json, completionHandler: callback)
    }
    
    private func doService(method : String, url : String, body : NSDictionary?, completionHandler :  (NSDictionary?, NSURLResponse?, NSError?) -> Void) {
        
        let fullURL = NSURL(string: Constants.BASE_URL + url)
        print("complete url \(fullURL)")
        let request = NSMutableURLRequest(URL: fullURL!)
        request.HTTPMethod = method
        
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
            print("Request Body, \(body?.description)")
        }
        //create session
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            dispatch_async(dispatch_get_main_queue(), { 
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            let dict = self.createJSONFromData(data)
            print("Response data, \(dict)")
            if let httpResponse = response as? NSHTTPURLResponse {
                let code =  httpResponse.statusCode
                if code == 404 || code == 400 || code == 401{
                    let someError = NSError(domain: "com.communicator", code: code, userInfo: nil)
                    completionHandler(dict, response, someError)
                    return
                }
                completionHandler(dict, response, error)
            }
            
        })
        
        //intitilze session
        task.resume()
    }
    
    func createJSONFromData(data: NSData?) -> NSDictionary? {
        var json: NSDictionary? = nil
        if let _ = data {
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? NSDictionary
                if json == nil {
                    let arrayData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue : 0)) as? NSArray
                    if arrayData != nil {
                        json = [ "messages": arrayData!]
                    }
                }
            } catch {
                json = nil
            }
        }
        
        return json
    }
}
