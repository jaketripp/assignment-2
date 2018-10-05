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
    
    // Struct for form items tag constants
    struct FormItems {
        static let name = "name"
        static let email = "email"
        static let street = "street"
        static let city = "city"
        static let state = "state"
        static let zip = "zip"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: have a variable, formTitle set by selecting vs create new segue
        // TODO: Update $(name)'s information
        // TODO: Create new CM Customer
        form +++ Section("About You")
            
            // MARK: - NAME
            <<< TextRow(FormItems.name) {
                $0.title = "Name"
                $0.placeholder = "John Smith"
                $0.value = ""
                $0.add(rule: RuleRequired(msg: "Name field required!"))
                // TODO: change validation to not allow any crazy characters? use for city and address
                $0.add(rule: RuleClosure<String> { input in
                    let decimalCharacters = CharacterSet.decimalDigits
                    let decimalRange = input?.rangeOfCharacter(from: decimalCharacters)
                    if decimalRange != nil {
                        return ValidationError(msg: "Names must not contain numbers!")
                    } else {
                        return nil
                    }
                })
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = validationMsg
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            // MARK: - EMAIL
            <<< EmailRow(FormItems.email) {
                $0.title = "Email"
                $0.placeholder = "john.smith@gmail.com"
                $0.add(rule: RuleEmail())
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = validationMsg
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            // MARK: - ADDRESS
            <<< TextRow(FormItems.street) {
                $0.title = "Address"
                $0.placeholder = "123 Apple Street"
            }
            
            // MARK: - CITY
            <<< TextRow(FormItems.city) {
                $0.title = "City"
                $0.placeholder = "San Antonio"
            }
            
            // MARK: - STATE
            <<< PickerInlineRow<String>(FormItems.state) { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "State"
                row.noValueDisplayText = "Pick a state"
                row.options = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
                
            }
            
            // MARK: - ZIP
            <<< ZipCodeRow(FormItems.zip) {
                $0.title = "Zip Code"
                $0.placeholder = "12345"
                $0.add(rule: RuleExactLength(exactLength: 5))
                $0.add(rule: RuleClosure<String> { input in
                    if input != nil, let _ = Int(input!) {
                        return nil
                    } else {
                        return ValidationError(msg: "Zip codes must only contain numbers!")
                    }
                })
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = validationMsg
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
    }
}
