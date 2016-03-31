//
//  ViewController.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------
// MARK: - ViewController: UIViewController
//------------------------------------------------

class ViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var left = ArrayOfArrays()
        left.append(Array(arrayLiteral: 1, 3, 9, 6))
        left.append(Array(arrayLiteral: 5, 8, 4, 6))
        left.append(Array(arrayLiteral: 2, 9, 7, 6))
        left.append(Array(arrayLiteral: 4, 3, 4, 6))
        
        var right = ArrayOfArrays()
        right.append(Array(arrayLiteral: 2, 3, 1, 5))
        right.append(Array(arrayLiteral: 6, 1, 4, 6))
        right.append(Array(arrayLiteral: 9, 9, 7, 8))
        right.append(Array(arrayLiteral: 4, 4, 3, 6))
        
        MatrixMathApiClient.sharedInstance.addition(left, right: right) { (json, error) in
            performOnMain {
                guard error == nil else {
                    print("An error occured: \(error!.localizedDescription)")
                    return
                }
                
                guard let json = json else {
                    print("Receive an empty response")
                    return
                }
                
                guard let result = json[MatrixMathApiClient.JSONResponseKey.Result] as? ArrayOfArrays else {
                    print("Failed to access JSON data with the `\(MatrixMathApiClient.JSONResponseKey.Result)` key")
                    return
                }
                
                print("Result: \(result)")
            }
        }
    }
    
}

