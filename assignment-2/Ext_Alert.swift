//
//  Alert.swift
//  assignment-2
//
//  Created by Tripp,Jacob on 10/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

extension RootViewController {
    func showCustomerActionFailureAlert(title: String, message: String) {
        let realMessage = "\(message) Please check your internet connection or try again later."
        let alert = UIAlertController(title: title, message: realMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
