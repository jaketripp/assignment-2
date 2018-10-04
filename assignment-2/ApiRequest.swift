//
//  ApiRequest.swift
//  forceios-template
//
//  Created by Tripp,Jacob on 10/3/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore
import SalesforceSwiftSDK
import PromiseKit

class ApiRequest: NSObject {
    
    func getDataRows(completion: @escaping (([[String: Any]]) -> Void)) {
        let restApi = SFRestAPI.sharedInstance()
        let soqlQuery = "SELECT Name, State__c FROM CM_Customer__c LIMIT 10"
        
        restApi.performSOQLQuery(soqlQuery, fail: { (error, response) in
            
            SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
            
        }, complete: { (json, httpResponse) in
            
            if let dict = json as? [String: Any], let records = dict["records"] as? [[String: Any]] {
                completion(records)
            }
            
        })
    }
    
}
