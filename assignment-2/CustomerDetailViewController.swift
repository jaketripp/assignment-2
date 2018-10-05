//
//  CustomerDetailViewController.swift
//  assignment-2
//
//  Created by Tripp,Jacob on 10/4/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import Eureka

class CustomerDetailViewController: FormViewController {
    // TODO: have a customer variable for the values? house them all inside one varialbe that way
    // TODO: have them start off as empty values?
    // TODO: maybe change customer model to be able to be initiliazed without any data and just have empty variables?
    
//    ["Name": "Jake Tripp",
//    "Email__c": "shmogens@gmail.com",
//    "Address__c": "123 Apple Street",
//    "City__c": "San Antonio",
//    "State__c": "TX",
//    "Zip__c": "78209"]
    var customer : Customer = Customer([:])
    
    /// Track current form state
    enum currentAction {
        case updating
        case creating
    }
    var userIsCurrently : currentAction = .updating
    
    // Struct for form items tag constants
    struct FormItems {
        static let name = "name"
        static let email = "email"
        static let street = "street"
        static let city = "city"
        static let state = "state"
        static let zip = "zip"
        static let submitButton = "submitButton"
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        Validation.setEurekaRowDefaults()
        
        // TODO: have a variable, formTitle set by selecting vs create new segue
        let sectionTitle = userIsCurrently == .updating ? "Update info" : "Create a new customer"
        let buttonText = userIsCurrently == .updating ? "Update" : "Create"
        
        // TODO: Try to query and validate the address, city, state, zip
        form +++ Section(sectionTitle)
            // MARK: - NAME
            <<< TextRow(FormItems.name) {
                $0.title = "Name"
                $0.placeholder = "John Smith"
                $0.value = customer.name
                $0.add(rule: RuleRequired(msg: "Name field required!"))
                $0.add(rule: RuleMaxLength(maxLength: 80, msg: "Name cannot be longer than 80 characters!"))
            }
            
            // MARK: - EMAIL
            <<< EmailRow(FormItems.email) {
                $0.title = "Email"
                $0.placeholder = "john.smith@gmail.com"
                $0.value = customer.email
                $0.add(rule: RuleEmail())
            }
            
            // MARK: - ADDRESS
            <<< TextRow(FormItems.street) {
                $0.title = "Address"
                $0.placeholder = "123 Apple Street"
                $0.value = customer.street
                $0.add(rule: RuleMaxLength(maxLength: 255, msg: "Address cannot be longer than 255 characters!"))
            }
            
            // MARK: - CITY
            <<< TextRow(FormItems.city) {
                $0.title = "City"
                $0.placeholder = "San Antonio"
                $0.value = customer.city
                $0.add(rule: RuleMaxLength(maxLength: 255, msg: "City cannot be longer than 80 characters!"))
            }
            
            // MARK: - STATE
            <<< PickerInlineRow<String>(FormItems.state) { (row : PickerInlineRow<String>) -> Void in
                row.title = "State"
                row.noValueDisplayText = "Pick a state"
                row.options = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
                row.value = customer.state
            }
            
            // MARK: - ZIP
            <<< ZipCodeRow(FormItems.zip) {
                $0.title = "Zip Code"
                $0.placeholder = "12345"
                $0.value = customer.zip
                $0.add(rule: RuleExactLength(exactLength: 5))
                $0.add(rule: RuleClosure<String> { input in
                    // if it's nil or empty, do nothing
                    if  (input ?? "").isEmpty {
                        return nil
                    // if it can be casted to an int, do nothing
                    } else if input != nil, let _ = Int(input!) {
                        return nil
                    } else {
                        return ValidationError(msg: "Zip codes must only contain numbers!")
                    }
                })
            }
            <<< ButtonRow(FormItems.submitButton) {
                $0.title = buttonText
//                $0.presentationMode = .segueName(segueName: "RowsExampleViewControllerSegue", onDismiss: nil)
                $0.onCellSelection({ (cell, row) in
                    if let validationErrors : [ValidationError] = row.section?.form?.validate(), validationErrors.isEmpty {
                        // happy path, send request
                        // print("yep")
                    } else {
                        // sad path, maybe show an alert? although errors will already be visible
                        // print("nope")
                    }
                })
            }
        
    }
    
    
}
