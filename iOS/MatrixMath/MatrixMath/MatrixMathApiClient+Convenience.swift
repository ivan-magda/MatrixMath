//
//  MatrixMathApiClient+Convenience.swift
//  MatrixMath
//
//  Created by Ivan Magda on 14.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-----------------------------------------
// MARK: - MatrixMathApiClient+Convenience
//-----------------------------------------

extension MatrixMathApiClient {
    
    func performMatrixOperationWithType(type: MatrixOperationType, matrices: [Matrix], withCompletionHandler completionHandler: MatrixMathMatrixResultBlock) {
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            let error = NSError(domain: MatrixMathApiClient.ErrorDomain,
                                code: MatrixMathApiClient.ErrorCode,
                                userInfo: userInfo)
            completionHandler(matrix: nil, error: error)
        }
        
        guard matrices.count <= 2 else {
            sendError("Max size of the passed in matrices is equal to 2")
            return
        }
        
        switch type {
        case .Addition:
            addition(left: matrices[0], right: matrices[1], completionHandler: completionHandler)
        case .Subtract:
            subtract(left: matrices[0], right: matrices[1], completionHandler: completionHandler)
        case .Multiply:
            multiply(left: matrices[0], right: matrices[1], completionHandler: completionHandler)
        case .Transpose:
            transpose(matrix: matrices[0], completionHandler: completionHandler)
        case .Invert:
            invert(matrix: matrices[0], completionHandler: completionHandler)
        default:
            sendError("Incorrect matrix operation type")
        }
    }
    
    func performSolveOperationWithType(type: MatrixOperationType, coefficientsMatrix matrix: Matrix, valuesVector vector: Array<Double>, completionHandler: MatrixMathSystemSolutionResultBlock) {
        switch type {
        case .Solve:
            solve(coefficientsMatrix: matrix, valuesVector: vector, completionHandler: completionHandler)
        case .SolveWithErrorCorrection:
            solveWithErrorCorrection(coefficientsMatrix: matrix, valuesVector: vector, completionHandler: completionHandler)
        default:
            let userInfo = [NSLocalizedDescriptionKey: "Incorrect matrix operation type"]
            let error = NSError(domain: MatrixMathApiClient.ErrorDomain,
                                code: MatrixMathApiClient.ErrorCode,
                                userInfo: userInfo)
            completionHandler(vector: nil, error: error)
        }
    }
    
}
