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
    func getDataRows(completion: @escaping (([String : Customer]) -> Void)) {
        let soqlQuery = "SELECT Id, Name, Email__c, Address__c, City__c, State__c, Zip__c, LastModifiedDate FROM CM_Customer__c WHERE State__c != NULL ORDER BY LastModifiedDate DESC LIMIT 25"
        
        restApi.performSOQLQuery(soqlQuery, fail: { (error, response) in
            
            SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
            SFUserAccountManager.sharedInstance().logout()
            
        }, complete: { (json, httpResponse) in
            
            if let dict = json as? [String : Any], let records = dict["records"] as? [[String: Any]] {
                var customers = [String : Customer]()
                for customer in records {
                    if let id = customer["Id"] as? String {
                        customers[id] = Customer(customer)
                    }
                }
                completion(customers)
            }
            
        })
    }
    
    /// Send update request to SF
    func update(from oldCustomer: Customer, to newCustomer: Customer, completion: @escaping ((String?, Customer?, Error?) -> Void)) {
        let fields = newCustomer.asDictionary()
        if let id = oldCustomer.id {
            restApi.performUpdate(withObjectType: "CM_Customer__c", objectId: id, fields: fields,
                  fail: { (error, response) in
                    SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                    completion(id, oldCustomer, error)
                },
                  complete: { (json, httpResponse) in
                    print("customer updated")
                }
            )
            
        }
    }
    
    /// Send create request to SF
    func create(_ customer: Customer, _ fakeId: String, completion: @escaping ((String?, String?, Customer?, Error?) -> Void)) {
        let fields = customer.asDictionary()
        
        restApi.performCreate(withObjectType: "CM_Customer__c", fields: fields,
            fail: { (error, response) in
                SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                completion(fakeId, nil, nil, error)
            },
            complete: { (json, httpResponse) in
                
                if let dict = json as? [String : Any],
                    let realId = dict["id"] as? String {
                    
                    var newCustomer = customer
                    newCustomer.id = realId

                    completion(fakeId, realId, newCustomer, nil)
                    print("customer created")
                }
            }
        )
    }
}
