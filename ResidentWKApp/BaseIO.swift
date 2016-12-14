//
//  BaseIO.swift
//  NetworkHandler
//
//  Created by Balram Singh on 14/05/16.
//  Copyright © 2016 Balram Singh. All rights reserved.
//

import UIKit

protocol BaseIO {
    func get(_ url: String, callback: (NSDictionary?, URLResponse?, NSError?) -> Void)
    
    func update(_ url: String, json: NSDictionary?, callback: (NSDictionary?, URLResponse?, NSError?) -> Void)
    
    func post(_ url: String, json: NSDictionary?, callback: (NSDictionary?, URLResponse?, NSError?) -> Void)
    
    func delete(_ url: String, json: NSDictionary?, callback:(NSDictionary?, URLResponse?, NSError?) -> Void)
}
