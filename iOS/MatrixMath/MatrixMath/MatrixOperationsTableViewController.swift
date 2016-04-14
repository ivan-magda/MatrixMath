//
//  ViewController.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------
// MARK: Types
//-----------------------------------------------------------------

private enum MatrixOperationTableViewCellReuseIdentifier: String {
    case Basic = "MatrixOperationTableViewCell"
    case Subtitle = "MatrixOperationDetailTableViewCell"
}

private enum SegueIdentifier: String {
    case ComputeOperation = "ComputeOperation"
}

//--------------------------------------------------------------------
// MARK: - MatrixOperationsTableViewController: UITableViewController
//--------------------------------------------------------------------

class MatrixOperationsTableViewController: UITableViewController {
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    var apiClient: MatrixMathApiClient!
    private var methods: [MatrixOperation]!
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(apiClient != nil, "Api client instance must be instantiated")
        
        // Back bar button item without title.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .Plain,
                                                                target: nil,
                                                                action: nil)
        methods = MatrixOperation.getAllMethods()
    }
    
    //------------------------------------------------
    // MARK: Navigation
    //------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ComputeOperation.rawValue {
            guard let operation = sender as? MatrixOperation else {
                return
            }
            
            print("Select \(operation.name) method")
            
            let controller = segue.destinationViewController as! ComputeOperationViewController
            controller.operationToPerform = operation
            controller.apiClient = apiClient
        }
    }
    
    //------------------------------------------------
    // MARK: UITableViewDataSource
    //------------------------------------------------
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return methods.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.row == methods.count - 1 {
            cell = tableView.dequeueReusableCellWithIdentifier(MatrixOperationTableViewCellReuseIdentifier.Subtitle.rawValue)
            configureCell(cell, forRowAtIndexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(MatrixOperationTableViewCellReuseIdentifier.Basic.rawValue)
            configureCell(cell, forRowAtIndexPath: indexPath)
        }
        
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let method = methods[indexPath.row]
        
        cell.textLabel?.text = method.name
        
        if indexPath.row == methods.count - 1 {
            cell.detailTextLabel?.text = method.detailDescription
        }
    }
    
    //------------------------------------------------
    // MARK: UITableViewDelegate
    //------------------------------------------------
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier(SegueIdentifier.ComputeOperation.rawValue,
                                   sender: methods[indexPath.row])
    }
    
}

