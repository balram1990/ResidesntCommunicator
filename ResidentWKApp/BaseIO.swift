//
//  BaseIO.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

protocol BaseIO {
    func get(url: String, callback: (NSDictionary?, NSURLResponse?, NSError?) -> Void)
    
    func update(url: String, json: NSDictionary?, callback: (NSDictionary?, NSURLResponse?, NSError?) -> Void)
    
    func post(url: String, json: NSDictionary?, callback: (NSDictionary?, NSURLResponse?, NSError?) -> Void)
    
    func delete(url: String, json: NSDictionary?, callback:(NSDictionary?, NSURLResponse?, NSError?) -> Void)
}