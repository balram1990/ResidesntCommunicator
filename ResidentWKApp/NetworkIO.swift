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

class NetworkIO: NSObject {
    
    func get(_ url: String, callback: @escaping (NSDictionary?, URLResponse?, NSError?) -> Void) {
        doService("GET", url: url, body: nil, completionHandler: callback)
    }
    
    func post(_ url: String, json: NSDictionary?, callback: @escaping (NSDictionary?, URLResponse?, NSError?) -> Void) {
        doService("POST", url: url, body: json, completionHandler: callback)
    }
    
    func update(_ url: String, json: NSDictionary?, callback: @escaping (NSDictionary?, URLResponse?, NSError?) -> Void) {
        doService("PUT", url: url, body: json, completionHandler: callback)
    }
    
    func delete(_ url: String, json: NSDictionary?, callback: @escaping (NSDictionary?, URLResponse?, NSError?) -> Void) {
        doService("DELETE", url: url, body: json, completionHandler: callback)
    }
    
    func doService(_ method : String, url : String, body : NSDictionary?, completionHandler :  @escaping (NSDictionary?, URLResponse?, NSError?) -> Void) {
        
        let fullURL = URL(string: Constants.BASE_URL + url)
        print("complete url \(fullURL)")
        let request = NSMutableURLRequest(url: fullURL!)
        request.httpMethod = method
        
        if  let _ = body {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var jsonData: Data? = nil
            do  {
                jsonData = try JSONSerialization.data(withJSONObject: body!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            } catch {
               print("Something went wrong while parsing JSON")
            }
            request.httpBody = jsonData
            print("Request Body, \(body?.description)")
        }
        //create session
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
            DispatchQueue.main.async(execute: { 
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let dict = self.createJSONFromData(data)
            print("Response data, \(dict)")
            if let httpResponse = response as? HTTPURLResponse {
                let code =  httpResponse.statusCode
                if code == 404 || code == 400 || code == 401{
                    let someError = NSError(domain: "com.communicator", code: code, userInfo: nil)
                    completionHandler(dict, response, someError)
                    return
                }
                completionHandler(dict, response, error as NSError?)
            }
            
        })
        
        //intitilze session
        task.resume()
    }
    
    func createJSONFromData(_ data: Data?) -> NSDictionary? {
        var json: NSDictionary? = nil
        if let _ = data {
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                if json == nil {
                    let arrayData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue : 0)) as? NSArray
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
