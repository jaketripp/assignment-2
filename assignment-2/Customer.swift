//
//  Customer.swift
//  assignment-1
//
//  Created by Tripp,Jacob on 9/25/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

struct Customer {
    var name    : String?
    var email   : String?
    var street  : String?
    var city    : String?
    var state   : String?
    var zip     : String?
    var id      : String?
    
    init(_ data: [String: Any]) {
        self.name   = data["Name"] as? String
        self.email  = data["Email__c"] as? String
        self.street = data["Address__c"] as? String
        self.city   = data["City__c"] as? String
        self.state  = data["State__c"] as? String
        self.zip    = data["Zip__c"] as? String
        self.id     = data["Id"] as? String
    }
    
    /// returns Bool of whether current data is equivalent to a passed Customer object.
    static func ==(left: Customer, right: Customer) -> Bool {
        return left.name == right.name &&
                left.email == right.email &&
                left.street == right.street &&
                left.city == right.city &&
                left.state == right.state &&
                left.zip == right.zip
    }
    
    func asDictionary() -> [String:Any] {
        var data = [String:Any]()
        data["Name"] = self.name
        data["Email__c"] = self.email ?? ""
        data["Address__c"] = self.street ?? ""
        data["City__c"] = self.city ?? ""
        data["State__c"] = self.state ?? ""
        data["Zip__c"] = self.zip ?? ""
        return data
    }
}
