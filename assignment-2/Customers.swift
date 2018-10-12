//
//  Customers.swift
//  assignment-2
//
//  Created by Tripp,Jacob on 10/11/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore
import SalesforceSwiftSDK
import PromiseKit

class Customers: NSObject {
    var dictionary : [String : Customer] = [:]
    let restApi = SFRestAPI.sharedInstance()
    
    /// Get the initial customers' data
    func get(completion: @escaping (() -> Void)) {
        
        let soqlQuery = "SELECT Id, Name, Email__c, Address__c, City__c, State__c, Zip__c, LastModifiedDate FROM CM_Customer__c ORDER BY LastModifiedDate DESC LIMIT 100"
        let getRequest = restApi.request(forQuery: soqlQuery)
        
        restApi.Promises.send(request: getRequest)
            .done { response in
                if let records = response.asJsonDictionary()["records"] as? [[String: Any]] {
                    for customer in records {
                        if let id = customer["Id"] as? String {
                            self.dictionary[id] = Customer(customer)
                        }
                    }
                    completion()
                }
            }
            .catch { error in
                SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                SFUserAccountManager.sharedInstance().logout()
            }
    }
    
    /// Send create request to SF
    func create(_ customer: Customer, _ fakeId: String,
                completion: @escaping ((String, String?, Customer?, Error?) -> Void)) {
        let fields = customer.asDictionary()
        let createRequest = restApi.requestForCreate(withObjectType: "CM_Customer__c", fields: fields)
        
        restApi.Promises.send(request: createRequest)
            .done { response in
                let dict = response.asJsonDictionary()
                if let realId = dict["id"] as? String {
                    var newCustomer = customer
                    newCustomer.id = realId
                    
                    print("customer created")
                    completion(fakeId, realId, newCustomer, nil)
                }
            }
            .catch { error in
                SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                completion(fakeId, nil, nil, error)
            }
    }
    
    /// Send update request to SF
    func update(from oldCustomer: Customer, to newCustomer: Customer,
                completion: @escaping ((String, Customer, Error?) -> Void)) {
        let fields = newCustomer.asDictionary()
        if let id = oldCustomer.id {
            let updateRequest = restApi.requestForUpdate(withObjectType: "CM_Customer__c", objectId: id, fields: fields)
            
            restApi.Promises.send(request: updateRequest)
                .done { _ in
                    // no need for completion because we aren't doing anything
                    print("customer updated")
                }
                .catch { error in
                    SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
                    completion(id, oldCustomer, error)
                }
        }
    }
    
    /// Send delete request to SF
    func delete(id: String, completion: @escaping ((NSError?) -> Void)) {
        let deleteRequest: SFRestRequest = restApi.requestForDelete(withObjectType: "CM_Customer__c", objectId: id)
        
        restApi.Promises.send(request: deleteRequest)
            .done { response  in
                print("customer deleted")
                completion(nil)
            }
            .catch { error in
                let e = error as NSError
                print(e)
                completion(e)
        }
    }
}
