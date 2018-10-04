//
//  Customer.swift
//  assignment-1
//
//  Created by Tripp,Jacob on 9/25/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore
import SalesforceSwiftSDK
import PromiseKit

struct Customer {
    var name    : String?
    var email   : String?
    var street  : String?
    var city    : String?
    var state   : String?
    var zip     : Int?
    var id      : String?
    var fields  : [String : Any]
    
    init(_ data: [String: Any]) {
        self.name   = data["Name"] as? String
        self.email  = data["Email__c"] as? String
        self.street = data["Address__c"] as? String
        self.city   = data["City__c"] as? String
        self.state  = data["State__c"] as? String
        self.zip    = data["Zip__c"] as? Int
        self.id     = data["Id"] as? String
        self.fields = ["Time_Email_Sent__c" : ""]
    }
    
    /// Return customer content in large formatted string
//    func toString() -> String {
//        return """
//        Name: \(self.name ?? "")
//        Email: \(self.email ?? "")
//        Address: \(self.street ?? "")
//        City: \(self.city ?? "")
//        State: \(self.state ?? "")
//        Zip: \(self.zip != nil ? String(zip!) : "")
//        """
//    }
}
