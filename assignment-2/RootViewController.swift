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
    // MARK: - DATA
    var dataRows : [Customer] = [Customer]()
    var APIRequester : ApiRequest = ApiRequest()
    var isAscending : Bool = true
    private var deleteRequests = [Int:DeletedCustomerInfo]()
    
    // MARK: - View lifecycle
    override func loadView() {
        super.loadView()
        
        getAndLoadData()
    }
    
    func getAndLoadData() {
        APIRequester.getDataRows { (response) in
            self.dataRows = self.sort(response, by: .name)
            SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"request:didLoadResponse: #records: \(self.dataRows.count)")
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.dataRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "tableViewCell"
        
        // Dequeue or create a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) as! TableViewCell
        
        // If you want to add an image to your cell, here's how.
        // let image = UIImage(named: "central-market-logo.png")
        // cell!.imageView!.image = image
        
        // Configure the cell to show the data.
        let customer = dataRows[indexPath.row]
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
            self.sortBasedOnSegmentState()
            self.tableView.reloadData()
        })
    }
    
    
    // MARK: - SORT
    @IBOutlet weak var sortSegmentController: UISegmentedControl!
    
    func sortBasedOnSegmentState() {
        let scIndex = sortSegmentController.selectedSegmentIndex
        switch scIndex {
        case 0:
            self.dataRows = sort(self.dataRows, by: .name)
        case 1:
            self.dataRows = sort(self.dataRows, by: .state)
        default:
            print("Error: a non-available segment control button was pressed")
        }
    }
    
    @IBAction func sortTapped(_ sender: UISegmentedControl) {
        reloadTableData()
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
        self.dataRows = self.dataRows.reversed()
        reloadTableData()
    }
    
    
    // MARK: - UPDATE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateCustomerDetail" {
            if let destination = segue.destination as? CustomerDetailViewController {
                destination.userIsCurrently = .updating
                destination.customers = self.dataRows
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedRow = indexPath.row
                    
                    destination.customerIndex = selectedRow
                    destination.testController = self                }
                
            }
        } else if segue.identifier == "toCreateCustomerDetail" {
            if let destination = segue.destination as? CustomerDetailViewController {
                destination.userIsCurrently = .creating
                destination.customers = self.dataRows
                destination.testController = self
            }
        }
    }
    
    
    // MARK: - DELETE
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (indexPath.row < self.dataRows.count) {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        if (row < self.dataRows.count && editingStyle == UITableViewCellEditingStyle.delete) {
            let customer = self.dataRows[row]
            let deletedId: String = customer.id!
            let deletedCustomerInfo = DeletedCustomerInfo(data: customer, path:indexPath)
            let restApi = SFRestAPI.sharedInstance()
            
            let deleteRequest: SFRestRequest = restApi.requestForDelete(withObjectType: "CM_Customer__c",
                                                                        objectId: deletedId)
            restApi.Promises.send(request: deleteRequest)
                .done { [weak self] response  in
                    DispatchQueue.main.async {
                        self?.deleteRequests[deleteRequest.hashValue] = deletedCustomerInfo
                        // TODO: Change to fadeout instead of just vanish
                        self?.dataRows.remove(at:row)
                        self?.tableView.reloadData()
                    }
                }
                .catch{ [weak self] error in
                    let e = error as NSError
                    self?.reinstateDeletedRowWithRequest(deleteRequest)
                    self?.showErrorAlert(e as NSError, request: deleteRequest)
                }
        }
    }
    
    func reinstateDeletedRowWithRequest(_ request:SFRestRequest) {
        // Reinsert deleted rows if the operation is DELETE and the ID matches the deleted ID.
        // The trouble is, the NSError parameter doesn't give us that info, so we can't really
        // judge which row caused this error.
        
        DispatchQueue.main.async {
            if let rowValue = self.deleteRequests[request.hashValue] {
                // the beginning of the dataRows dictionary (index 0).
                self.dataRows.insert(rowValue.data, at: 0)
                self.tableView.reloadData()
                self.deleteRequests.removeValue(forKey: request.hashValue as Int)
            }
        }
    }
    
    private func showErrorAlert(_ error: NSError, request: SFRestRequest) {
        DispatchQueue.main.async {
            let errArray = error.userInfo["error"] as! [Any]
            if errArray.count > 0 {
//                let dictionary =  errArray[0] as! [String:Any]
//                let message = (dictionary["message"] as? String) ?? "Failed to delete item"
                let message = "Something went wrong. Sorry! Please try again later."
                let title = "Failed to delete customer"
                self.showAlert(title: title, message: message)
            }
        }
    }
}
