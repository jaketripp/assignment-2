/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore
import SalesforceSwiftSDK
import PromiseKit

/// User's current sort preference. Default is name.
enum SortBy {
    case name
    case state
}

class RootViewController : UITableViewController, CustomerDetailProtocol {
    
    // MARK: - DATA / VARIABLES
    var customers = Customers()
    private var shouldSortBy : SortBy = .name
    private var isAscending : Bool = true
    private var myRefreshControl : UIRefreshControl?
    
    /// An array of the customers dictionary values. Automatically sorts itself based on variable state. No setters (intentional).
    var customerList : [Customer] {
        get {
            let customers = Array(self.customers.dictionary.values)
            return sort(customers, by: shouldSortBy, isAscending: isAscending)
        }
    }
    
    // MARK: - View lifecycle
    override func loadView() {
        super.loadView()
        getAndLoadData()
        addRefreshControl()
    }
    
    @objc func getAndLoadData() {
        customers.get {
            self.reloadTableData()
            DispatchQueue.main.async(execute: {
                self.refreshControl?.endRefreshing()
            })
            SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"request:didLoadResponse: #records: \(self.customerList.count)")
        }
    }
    
    // MARK: - REFRESH CONTROL
    func addRefreshControl() {
        myRefreshControl = UIRefreshControl()
        myRefreshControl?.tintColor = UIColor.CMgreen
        myRefreshControl?.addTarget(self, action: #selector(getAndLoadData), for: UIControlEvents.valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    // MARK: - TABLE VIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.customerList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "tableViewCell"
        
        // Dequeue or create a cell of the appropriate type.
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier)!
        
        // If you want to add an image to your cell, here's how.
        // let image = UIImage(named: "central-market-logo.png")
        // cell!.imageView!.image = image
        
        // Configure the cell to show the data.
        let customer = self.customerList[indexPath.row]
        let name = customer.name!
        let state = customer.state
        let formattedState = state != nil ? "- \(state!)" : ""
        cell.textLabel?.text = "\(name) \(formattedState)"
        
        // Central Market Font ??????
        // cell!.textLabel!.font = UIFont(name: "TrendHMSansOne", size: 25)
        
        // This adds the arrow to the right hand side.
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
        
    }
    
    func reloadTableData() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    // MARK: - SORT
    @IBOutlet weak var sortSegmentController: UISegmentedControl!
    
    @IBAction func sortTapped(_ sender: UISegmentedControl) {
        DispatchQueue.main.async(execute: {
            let scIndex = self.sortSegmentController.selectedSegmentIndex
            switch scIndex {
            case 0:
                self.shouldSortBy = .name
            case 1:
                self.shouldSortBy = .state
            default:
                print("Error: a non-available segment control button was pressed")
                self.shouldSortBy = .name
            }
            self.reloadTableData()
        })
        
    }
    
    func sort(_ customers: [Customer], by whatToSortBy: SortBy, isAscending: Bool) -> [Customer] {
        switch whatToSortBy {
        case .name:
            if (isAscending) {
                return customers.sorted { $0.name ?? "" < $1.name ?? "" }
            } else {
                return customers.sorted { $0.name ?? "" > $1.name ?? "" }
            }
        case .state:
            if (isAscending) {
                return customers.sorted { $0.state ?? "" < $1.state ?? "" }
            } else {
                return customers.sorted { $0.state ?? "" > $1.state ?? "" }
            }
        }
    }
    
    
    // MARK: - REVERSE
    @IBOutlet weak var ascOrDesc: UIButton!
    @IBAction func ascOrDescPressed(_ sender: UIButton) {
        isAscending = !isAscending
        let imageName = isAscending ? "asc" : "desc"
        ascOrDesc.setImage(UIImage(named: imageName), for: .normal)
        self.reloadTableData()
    }
    
    
    // MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateCustomerDetail" {
            if let destination = segue.destination as? CustomerDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                
                let selectedRow = indexPath.row
                destination.userIsCurrently = .updating
                destination.customers = self.customers
                destination.customer = self.customerList[selectedRow]
                destination.delegate = self
                
            }
        } else if segue.identifier == "toCreateCustomerDetail" {
            if let destination = segue.destination as? CustomerDetailViewController {
                destination.userIsCurrently = .creating
                destination.customers = self.customers
                destination.customer = Customer([:])
                destination.delegate = self
            }
        }
    }
    
    
    // MARK: - DELETE
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (indexPath.row < self.customerList.count) {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        if (row < self.customerList.count && editingStyle == UITableViewCellEditingStyle.delete) {
            let customer = self.customerList[row]
            let deletedId: String = customer.id!
            // update UI first
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.customers.dictionary[deletedId] = nil
                /// delete rows with pretty animation
                self.tableView.deleteRows(at: [indexPath], with: .left)
                self.tableView.endUpdates()
            }
            
            customers.delete(id: deletedId) { (e) in
                if e != nil {
                    self.reinstateDeletedRowWithRequest(customer, deletedId, indexPath)
                    self.showErrorAlert(e!)
                }
            }
        }
    }
    
    /// re-insert customers if delete failed
    func reinstateDeletedRowWithRequest(_ customer: Customer, _ id: String, _ indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.tableView.beginUpdates()
            self.customers.dictionary[id] = customer
            /// re-insert rows that weren't successfully deleted with pretty animation
            self.tableView.insertRows(at: [indexPath], with: .left)
            self.tableView.endUpdates()
        }
    }
    
    private func showErrorAlert(_ error: NSError) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let message = "Sorry, we couldn't delete that customer."
            let title = "Unable to delete customer"
            self.showCustomerActionFailureAlert(title: title, message: message)
        }
    }
}
