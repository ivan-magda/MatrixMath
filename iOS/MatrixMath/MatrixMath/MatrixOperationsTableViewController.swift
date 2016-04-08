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
    
    private var methods: [MatrixOperation]!
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Back button without title.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain,
                                                                target: nil, action: nil)
        
        methods = MatrixOperation.getAllMethods()
        
        if false {
            var left = MatrixDataType()
            left.append(Array(arrayLiteral: 1, 3, 9, 6))
            left.append(Array(arrayLiteral: 5, 8, 4, 6))
            left.append(Array(arrayLiteral: 2, 9, 7, 6))
            left.append(Array(arrayLiteral: 4, 3, 4, 6))
            
            var right = MatrixDataType()
            right.append(Array(arrayLiteral: 2, 3, 1, 5))
            right.append(Array(arrayLiteral: 6, 1, 4, 6))
            right.append(Array(arrayLiteral: 9, 9, 7, 8))
            right.append(Array(arrayLiteral: 4, 4, 3, 6))
            
            let lftMatrix = Matrix(data: left)
            let rghMatrix = Matrix(data: right)
            
            MatrixMathApiClient.sharedInstance.addition(left: lftMatrix, right: rghMatrix) { (matrix, error) in
                performOnMain {
                    guard error == nil else {
                        print("An error occured: \(error!.localizedDescription)")
                        return
                    }
                    
                    guard let matrix = matrix else {
                        print("Receive an empty response. There is no Matrix object.")
                        return
                    }
                    
                    print("Addition result: \(matrix.data)")
                }
            }
            
            MatrixMathApiClient.sharedInstance.invert(matrix: lftMatrix) { (matrix, error) in
                guard error == nil else {
                    print("An error occured: \(error!.localizedDescription)")
                    return
                }
                
                guard let matrix = matrix else {
                    print("Receive an empty response. There is no Matrix object.")
                    return
                }
                
                print("Invert result: \(matrix.data)")
            }
            
            MatrixMathApiClient.sharedInstance.determinant(matrix: lftMatrix) { (result, error) in
                guard error == nil else {
                    print("An error occured: \(error!.localizedDescription)")
                    return
                }
                
                guard let result = result else {
                    print("Receive an empty response. There is no Matrix object.")
                    return
                }
                
                print("Determinant = \(result)")
            }
            
            var solveArr = MatrixDataType()
            solveArr.append(Array(arrayLiteral: 1,2,3,4,5,6,7,8,9))
            solveArr.append(Array(arrayLiteral: 9,8,7,6,5,4,3,2,1))
            solveArr.append(Array(arrayLiteral: 25,1,2,3,4,5,6,7,8))
            solveArr.append(Array(arrayLiteral: 8,7,26,5,4,3,2,1,0))
            solveArr.append(Array(arrayLiteral: 10,1,2,3,14,5,6,7,8))
            solveArr.append(Array(arrayLiteral: 8,7,6,35,4,3,2,1,10))
            solveArr.append(Array(arrayLiteral: 1,3,5,7,99,7,5,3,1))
            solveArr.append(Array(arrayLiteral: 2,4,6,8,10,12,1,2,1))
            solveArr.append(Array(arrayLiteral: 2,4,6,8,10,12,1,2,1.001))
            
            let coefficients = Matrix(data: solveArr)
            let vector: [Double] = Array(arrayLiteral: 1, 2, 3, 4, 5, 6, 7, 8, 9)
            
            MatrixMathApiClient.sharedInstance.solve(coefficientsMatrix: coefficients, valuesVector: vector) { (vector, error) in
                guard error == nil else {
                    print("An error occured: \(error!.localizedDescription)")
                    return
                }
                
                guard let vector = vector else {
                    print("Receive an empty response. There is no Matrix object.")
                    return
                }
                
                print("Result vector: \(vector)")
            }
        }
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

