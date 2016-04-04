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

