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
    func isEquivalentTo(_ passedCustomer: Customer) -> Bool {
        return passedCustomer.name == self.name &&
                passedCustomer.email == self.email &&
                passedCustomer.street == self.street &&
                passedCustomer.city == self.city &&
                passedCustomer.state == self.state &&
                passedCustomer.zip == self.zip
    }
}
