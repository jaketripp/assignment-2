//
//  Validation.swift
//  assignment-2
//
//  Created by Tripp,Jacob on 10/5/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import Eureka

class Validation: NSObject {
    /// Sets default error handling for all the Eureka rows I'm using (make the text red and show the error)
    static func setEurekaRowDefaults() {
        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        TextRow.defaultOnRowValidationChanged = { cell, row in
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
        EmailRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        EmailRow.defaultOnRowValidationChanged = { cell, row in
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
        ZipCodeRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        ZipCodeRow.defaultOnRowValidationChanged = { cell, row in
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
