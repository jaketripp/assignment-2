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

class RootViewController : UITableViewController {
    
    // MARK: - DATA / VARIABLES
    var customerList : [Customer] = [Customer]()
    var customerDictionary = [String : Customer]()
    
    private var APIRequester : ApiRequest = ApiRequest()
    private var isAscending : Bool = true
    private var myRefreshControl : UIRefreshControl?
    private let restApi = SFRestAPI.sharedInstance()
    
    // MARK: - View lifecycle
    override func loadView() {
        super.loadView()
        getAndLoadData()
        addRefreshControl()
    }
    
    @objc func getAndLoadData() {
        APIRequester.getData { (response) in
            self.customerDictionary = response
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
        let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) as! TableViewCell
        
        // If you want to add an image to your cell, here's how.
        // let image = UIImage(named: "central-market-logo.png")
        // cell!.imageView!.image = image
        
        // Configure the cell to show the data.
        let customer = self.customerList[indexPath.row]
        let name = customer.name!
        let state = customer.state
        let formattedState = state != nil ? "- \(state!)" : ""
        cell.nameAndState.text = "\(name) \(formattedState)"
        
        // Central Market Font ??????
        // cell!.textLabel!.font = UIFont(name: "TrendHMSansOne", size: 25)
        
        // This adds the arrow to the right hand side.
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    func reloadTableData() {
        DispatchQueue.main.async(execute: {
            self.resetCustomerList()
            self.tableView.reloadData()
        })
    }
    
    func resetCustomerList() {
        self.customerList = Array(self.customerDictionary.values)
        self.sortBasedOnSegmentState()
    }
    
    // MARK: - SORT
    @IBOutlet weak var sortSegmentController: UISegmentedControl!
    
    @IBAction func sortTapped(_ sender: UISegmentedControl) {
        reloadTableData()
    }
    
    func sortBasedOnSegmentState() {
        let scIndex = sortSegmentController.selectedSegmentIndex
        switch scIndex {
            case 0:
                self.customerList = sort(self.customerList, by: .name)
            case 1:
                self.customerList = sort(self.customerList, by: .state)
            default:
                print("Error: a non-available segment control button was pressed")
        }
    }
    
    enum sortBy {
        case name
        case state
    }
    
    func sort(_ customers: [Customer], by whatToSortBy: sortBy) -> [Customer] {
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
        if (isAscending) {
            ascOrDesc.setImage(UIImage(named: "asc"), for: .normal)
        } else {
            ascOrDesc.setImage(UIImage(named: "desc"), for: .normal)
        }
        self.customerList = self.customerList.reversed()
        reloadTableData()
    }
    
    
    // MARK: - UPDATE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateCustomerDetail" {
            if let destination = segue.destination as? CustomerDetailViewController {
                destination.userIsCurrently = .updating
                destination.customers = self.customerList
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedRow = indexPath.row
                    
                    destination.customerIndex = selectedRow
                    destination.rootViewController = self
                    
                }
            }
        } else if segue.identifier == "toCreateCustomerDetail" {
            if let destination = segue.destination as? CustomerDetailViewController {
                destination.userIsCurrently = .creating
                destination.customers = self.customerList
                destination.rootViewController = self
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
                
                self.customerDictionary[deletedId] = nil
                self.resetCustomerList()
                
                /// delete rows with pretty animation
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
                self.tableView.endUpdates()
            }
            
            let deleteRequest: SFRestRequest = restApi.requestForDelete(withObjectType: "CM_Customer__c",
                                                                        objectId: deletedId)
            
            restApi.Promises.send(request: deleteRequest)
                .done { response  in
                    print("customer deleted")
                }
                // re-insert customers if delete failed
                .catch { [weak self] error in
                    let e = error as NSError
                    self?.reinstateDeletedRowWithRequest(customer, deletedId, indexPath)
                    self?.showErrorAlert(e as NSError, request: deleteRequest)
            }
        }
    }
    
    func reinstateDeletedRowWithRequest(_ customer: Customer, _ id: String, _ indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            self.tableView.beginUpdates()
            
            self.customerDictionary[id] = customer
            self.resetCustomerList()
            
            /// re-insert rows that weren't successfully deleted with pretty animation
            self.tableView.insertRows(at: [indexPath], with: .left)
            
            self.tableView.endUpdates()
            
        }
    }
    
    private func showErrorAlert(_ error: NSError, request: SFRestRequest) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // kept for reference for future projects
            let errArray = error.userInfo["error"] as? [Any] ?? [""]
            if errArray.count > 0 {
                let message = "Sorry, we couldn't delete that customer! Please check your internet connection or try again later."
                let title = "Unable to delete customer"
                self.showAlert(title: title, message: message)
            }
        }
    }
}
