//
//  Alert.swift
//  assignment-2
//
//  Created by Tripp,Jacob on 10/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

extension UITableViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
