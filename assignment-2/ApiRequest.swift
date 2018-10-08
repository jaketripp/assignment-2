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
    
    let restApi = SFRestAPI.sharedInstance()
    
    /// Get the initial data
    func getDataRows(completion: @escaping (([Customer]) -> Void)) {
        let soqlQuery = "SELECT Id, Name, Email__c, Address__c, City__c, State__c, Zip__c, LastModifiedDate FROM CM_Customer__c WHERE State__c != NULL ORDER BY LastModifiedDate DESC LIMIT 25"
        
        restApi.performSOQLQuery(soqlQuery, fail: { (error, response) in
            
            SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
            SFUserAccountManager.sharedInstance().logout()
            
        }, complete: { (json, httpResponse) in
            
            if let dict = json as? [String: Any], let records = dict["records"] as? [[String: Any]] {
                var customers = [Customer]()
                for customer in records {
                    customers.append(Customer(customer))
                }
                completion(customers)
            }
            
        })
    }
    
    /// Send update request to SF
    func update(_ customer: Customer, completion: @escaping ((Customer?, Error?) -> Void)) {
        let fields = customer.asDictionary()
        if let id = customer.id {
            
            restApi.performUpdate(withObjectType: "CM_Customer__c", objectId: id, fields: fields,
                  fail: { (error, response) in
//                    print(customer)
//                    print(response)
                    SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                    //                    SFUserAccountManager.sharedInstance().logout()
                    completion(nil, error)
                },
                  complete: { (json, httpResponse) in
                    
                    //            if let dict = json as? [String: Any], let records = dict["records"] as? [[String: Any]] {
                    //                var customers = [Customer]()
                    //                for customer in records {
                    //                    customers.append(Customer(customer))
                    //                }
                    //
                    //            }
//                    print(json)
                    completion(customer, nil)
                    
                }
            )
            
        }
    }
    
    /// Send create request to SF
    func create(_ customer: Customer, completion: @escaping ((Customer?, Error?) -> Void)) {
        let fields = customer.asDictionary()
        
        restApi.performCreate(withObjectType: "CM_Customer__c", fields: fields,
            fail: { (error, response) in
//                print(customer)
//                print(response)
                completion(nil, error)
                SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
            },
            complete: { (json, httpResponse) in
//                print(json)
                completion(customer, nil)
                
            }
        )
    }
}
